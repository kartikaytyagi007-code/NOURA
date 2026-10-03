/**
 * Minimal, dependency-free image byte sniffing and metadata stripping (blueprint §8 step 2: "backend
 * verifies actual bytes/type, dimensions and limits, strips metadata before AI"; AGENTS.md's frozen
 * stack bars adding a new image-processing dependency such as sharp/libvips for this).
 *
 * This deliberately does not decode pixel data or re-encode images: it reads container headers only,
 * which is enough to (a) prove the bytes are really the declared format rather than trusting the file
 * extension or a client-declared MIME type, (b) read dimensions for storage, and (c) strip the
 * metadata segments most likely to carry EXIF GPS/personal data before bytes ever reach an AI
 * provider. A file that is not a well-formed JPEG/PNG/WEBP is rejected rather than guessed at.
 */

export type SniffedMime = 'image/jpeg' | 'image/png' | 'image/webp';

export interface SniffedImage {
  mime: SniffedMime;
  width: number;
  height: number;
}

function sniffPng(bytes: Uint8Array): SniffedImage | null {
  const sig = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  if (bytes.length < 24 || !sig.every((b, i) => bytes[i] === b)) return null;
  // IHDR is always the first chunk, at offset 8 (length 4, type 'IHDR', then width/height).
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const chunkType = String.fromCharCode(bytes[12]!, bytes[13]!, bytes[14]!, bytes[15]!);
  if (chunkType !== 'IHDR') return null;
  const width = view.getUint32(16);
  const height = view.getUint32(20);
  if (width <= 0 || height <= 0) return null;
  return { mime: 'image/png', width, height };
}

function sniffJpeg(bytes: Uint8Array): SniffedImage | null {
  if (bytes.length < 4 || bytes[0] !== 0xff || bytes[1] !== 0xd8) return null;
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let offset = 2;
  while (offset + 4 <= bytes.length) {
    if (bytes[offset] !== 0xff) return null; // malformed marker stream
    const marker = bytes[offset + 1]!;
    if (marker === 0xd8 || marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      offset += 2;
      continue;
    }
    if (marker === 0xd9) break; // EOI with no SOF found
    const length = view.getUint16(offset + 2);
    if (length < 2 || offset + 2 + length > bytes.length) return null;
    const isSof =
      marker >= 0xc0 && marker <= 0xcf && marker !== 0xc4 && marker !== 0xc8 && marker !== 0xcc;
    if (isSof) {
      if (length < 7) return null;
      const height = view.getUint16(offset + 5);
      const width = view.getUint16(offset + 7);
      if (width <= 0 || height <= 0) return null;
      return { mime: 'image/jpeg', width, height };
    }
    offset += 2 + length;
  }
  return null;
}

function sniffWebp(bytes: Uint8Array): SniffedImage | null {
  if (bytes.length < 30) return null;
  const riff = String.fromCharCode(...bytes.slice(0, 4));
  const webp = String.fromCharCode(...bytes.slice(8, 12));
  if (riff !== 'RIFF' || webp !== 'WEBP') return null;
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const chunk = String.fromCharCode(...bytes.slice(12, 16));
  if (chunk === 'VP8 ') {
    // Simple lossy: dimensions are 14-bit values at a fixed offset after the frame tag.
    const width = view.getUint16(26, true) & 0x3fff;
    const height = view.getUint16(28, true) & 0x3fff;
    if (width <= 0 || height <= 0) return null;
    return { mime: 'image/webp', width, height };
  }
  if (chunk === 'VP8L') {
    const b0 = bytes[21]!;
    const b1 = bytes[22]!;
    const b2 = bytes[23]!;
    const b3 = bytes[24]!;
    const width = 1 + (((b1 & 0x3f) << 8) | b0);
    const height = 1 + (((b3 & 0x0f) << 10) | (b2 << 2) | (b1 >> 6));
    if (width <= 0 || height <= 0) return null;
    return { mime: 'image/webp', width, height };
  }
  if (chunk === 'VP8X') {
    const width = 1 + (bytes[24]! | (bytes[25]! << 8) | (bytes[26]! << 16));
    const height = 1 + (bytes[27]! | (bytes[28]! << 8) | (bytes[29]! << 16));
    if (width <= 0 || height <= 0) return null;
    return { mime: 'image/webp', width, height };
  }
  return null;
}

/** Reads the real container format and dimensions from bytes. Never trusts a declared MIME type. */
export function sniffImage(bytes: Uint8Array): SniffedImage | null {
  return sniffPng(bytes) ?? sniffJpeg(bytes) ?? sniffWebp(bytes);
}

export interface ImageValidationOptions {
  declaredMime: string;
  maxBytes: number;
  minDimensionPx?: number;
  maxDimensionPx?: number;
}

export type ImageValidationResult =
  | { ok: true; sniffed: SniffedImage }
  | {
      ok: false;
      reason: 'too_large' | 'not_an_image' | 'mime_mismatch' | 'dimensions_out_of_range';
    };

/** The single place upload-completion and the worker both call before trusting bytes as an image. */
export function validateImageBytes(
  bytes: Uint8Array,
  options: ImageValidationOptions,
): ImageValidationResult {
  if (bytes.length === 0 || bytes.length > options.maxBytes)
    return { ok: false, reason: 'too_large' };
  const sniffed = sniffImage(bytes);
  if (!sniffed) return { ok: false, reason: 'not_an_image' };
  if (sniffed.mime !== options.declaredMime) return { ok: false, reason: 'mime_mismatch' };
  const min = options.minDimensionPx ?? 32;
  const max = options.maxDimensionPx ?? 8000;
  if (sniffed.width < min || sniffed.height < min || sniffed.width > max || sniffed.height > max) {
    return { ok: false, reason: 'dimensions_out_of_range' };
  }
  return { ok: true, sniffed };
}

/**
 * Strips the JPEG APPn metadata segments (EXIF/APP1, ICC/APP2, Photoshop/APP13, XMP, etc.) before
 * bytes are sent to an AI provider. PNG/WEBP are passed through unchanged in this version: they are
 * accepted formats but carry metadata far less often in mobile capture flows, and a full ancillary
 * chunk stripper is left as a documented follow-up rather than guessed at here.
 */
export function stripImageMetadataForAi(bytes: Uint8Array, mime: SniffedMime): Uint8Array {
  if (mime !== 'image/jpeg') return bytes;
  if (bytes.length < 4 || bytes[0] !== 0xff || bytes[1] !== 0xd8) return bytes;
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const out: number[] = [0xff, 0xd8];
  let offset = 2;
  while (offset + 4 <= bytes.length) {
    if (bytes[offset] !== 0xff) break;
    const marker = bytes[offset + 1]!;
    if (marker === 0xd9) {
      out.push(0xff, 0xd9);
      break;
    }
    if (marker === 0xd8 || marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      out.push(0xff, marker);
      offset += 2;
      continue;
    }
    const length = view.getUint16(offset + 2);
    if (length < 2 || offset + 2 + length > bytes.length) {
      // Malformed tail; stop rewriting and keep the rest verbatim rather than corrupt the stream.
      for (let i = offset; i < bytes.length; i++) out.push(bytes[i]!);
      break;
    }
    const isAppSegment = marker >= 0xe0 && marker <= 0xef;
    const isComment = marker === 0xfe;
    if (!isAppSegment && !isComment) {
      for (let i = offset; i < offset + 2 + length; i++) out.push(bytes[i]!);
    }
    offset += 2 + length;
  }
  return Uint8Array.from(out);
}
