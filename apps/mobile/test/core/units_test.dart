import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/units/units.dart';
import 'package:noura_api_client/noura_api_client.dart';

void main() {
  test('converts with the exact international definitions', () {
    expect(lbToKg(1), closeTo(0.45359237, 1e-12));
    expect(kgToLb(0.45359237), closeTo(1, 1e-12));
    expect(feetInchesToCm(5, 0), closeTo(152.4, 1e-9));
    expect(feetInchesToCm(6, 2.5), closeTo(189.23, 1e-9));
  });

  test('splits centimetres into feet and inches and carries 12 inches up', () {
    expect(cmToFeetInches(162.56), (feet: 5, inches: 4.0));
    expect(cmToFeetInches(182.88), (feet: 6, inches: 0.0));
    // 11.97 in rounds to 12.0 and must become the next foot, not "5 ft 12 in".
    expect(cmToFeetInches(feetInchesToCm(5, 11.97)), (feet: 6, inches: 0.0));
  });

  test('round trips stay within display precision', () {
    for (final kg in [20.0, 45.5, 62.25, 99.9, 400.0]) {
      expect(round1(lbToKg(round1(kgToLb(kg)))), closeTo(kg, 0.1));
    }
    for (final cm in [50.0, 150.0, 162.5, 190.5, 272.0]) {
      final parts = cmToFeetInches(cm);
      expect(feetInchesToCm(parts.feet, parts.inches), closeTo(cm, 0.13));
    }
  });

  test('formats in the chosen unit system', () {
    expect(formatWeight(62, UnitSystem.metric), '62 kg');
    expect(formatWeight(62.25, UnitSystem.metric), '62.3 kg');
    expect(formatWeight(63.5, UnitSystem.imperial), '140 lb');
    expect(formatHeight(162.5, UnitSystem.metric), '162.5 cm');
    expect(formatHeight(162.56, UnitSystem.imperial), '5 ft 4 in');
  });

  test('parses decimals with a comma and rejects junk', () {
    expect(parseDecimal('62,5'), 62.5);
    expect(parseDecimal(' 70 '), 70);
    expect(parseDecimal(''), isNull);
    expect(parseDecimal('abc'), isNull);
    expect(parseDecimal('NaN'), isNull);
    expect(parseDecimal('Infinity'), isNull);
  });
}
