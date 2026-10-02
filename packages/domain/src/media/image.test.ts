import { describe, expect, it } from 'vitest';
import { sniffImage, stripImageMetadataForAi, validateImageBytes } from './image.js';

/** A minimal, hand-built PNG: signature + IHDR only. sniffImage only reads the header. */
function minimalPng(width: number, height: number): Uint8Array {
  const bytes = new Uint8Array(33);
  const sig = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  sig.forEach((b, i) => (bytes[i] = b));
  const view = new DataView(bytes.buffer);
  view.setUint32(8, 13); // IHDR chunk length
  'IHDR'.split('').forEach((c, i) => (bytes[12 + i] = c.charCodeAt(0)));
  view.setUint32(16, width);
  view.setUint32(20, height);
  bytes[24] = 8; // bit depth
  bytes[25] = 2; // color type
  return bytes;
}

/** A minimal, syntactically valid single-scan baseline JPEG with one APP1 (EXIF-like) segment. */
function minimalJpegWithExif(width: number, height: number): Uint8Array {
  const soi = [0xff, 0xd8];
  const app1Payload = Array.from({ length: 20 }, (_, i) => i); // pretend EXIF bytes
  const app1 = [0xff, 0xe1, 0x00, app1Payload.length + 2, ...app1Payload];
  const sof0Data = [
    0x08, // precision
    (height >> 8) & 0xff,
    height & 0xff,
    (width >> 8) & 0xff,
    width & 0xff,
    0x01, // components
    0x01,
    0x11,
    0x00,
  ];
  const sof0 = [0xff, 0xc0, 0x00, sof0Data.length + 2, ...sof0Data];
  const eoi = [0xff, 0xd9];
  return Uint8Array.from([...soi, ...app1, ...sof0, ...eoi]);
}

describe('sniffImage', () => {
  it('reads real PNG dimensions from the header, not a declared value', () => {
    const sniffed = sniffImage(minimalPng(640, 480));
    expect(sniffed).toEqual({ mime: 'image/png', width: 640, height: 480 });
  });

  it('reads real JPEG dimensions from the SOF0 marker', () => {
    const sniffed = sniffImage(minimalJpegWithExif(200, 100));
    expect(sniffed).toEqual({ mime: 'image/jpeg', width: 200, height: 100 });
  });

  it('returns null for bytes that are not a recognized image container (malicious/corrupt upload)', () => {
    expect(sniffImage(new TextEncoder().encode('<html>not an image</html>'))).toBeNull();
    expect(sniffImage(new Uint8Array([1, 2, 3, 4]))).toBeNull();
  });
});

describe('validateImageBytes', () => {
  it('accepts a well-formed image matching its declared mime', () => {
    const result = validateImageBytes(minimalPng(100, 100), {
      declaredMime: 'image/png',
      maxBytes: 1000,
    });
    expect(result.ok).toBe(true);
  });

  it('rejects oversized uploads', () => {
    const result = validateImageBytes(minimalPng(100, 100), {
      declaredMime: 'image/png',
      maxBytes: 10,
    });
    expect(result).toMatchObject({ ok: false, reason: 'too_large' });
  });

  it('rejects a declared mime that does not match the real bytes (a renamed/disguised file)', () => {
    const result = validateImageBytes(minimalPng(100, 100), {
      declaredMime: 'image/jpeg',
      maxBytes: 1000,
    });
    expect(result).toMatchObject({ ok: false, reason: 'mime_mismatch' });
  });

  it('rejects a non-image payload outright', () => {
    const result = validateImageBytes(new TextEncoder().encode('javascript:alert(1)'), {
      declaredMime: 'image/png',
      maxBytes: 1000,
    });
    expect(result).toMatchObject({ ok: false, reason: 'not_an_image' });
  });

  it('rejects dimensions outside the plausible range', () => {
    const result = validateImageBytes(minimalPng(1, 1), {
      declaredMime: 'image/png',
      maxBytes: 1000,
    });
    expect(result).toMatchObject({ ok: false, reason: 'dimensions_out_of_range' });
  });
});

describe('stripImageMetadataForAi', () => {
  it('removes JPEG APPn metadata segments before bytes reach an AI provider', () => {
    const withExif = minimalJpegWithExif(10, 10);
    const stripped = stripImageMetadataForAi(withExif, 'image/jpeg');
    expect(stripped.length).toBeLessThan(withExif.length);
    // Still a valid, parseable JPEG with the same dimensions after stripping.
    expect(sniffImage(stripped)).toEqual({ mime: 'image/jpeg', width: 10, height: 10 });
  });

  it('leaves non-JPEG bytes untouched', () => {
    const png = minimalPng(10, 10);
    expect(stripImageMetadataForAi(png, 'image/png')).toEqual(png);
  });
});
