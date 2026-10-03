import 'package:noura_api_client/noura_api_client.dart';

/// Unit helpers. The server stores and validates metric values only; imperial is a display and
/// input convenience (blueprint §5). Conversions use the exact international definitions.
const double kKgPerLb = 0.45359237;
const double kCmPerInch = 2.54;

double lbToKg(double lb) => lb * kKgPerLb;
double kgToLb(double kg) => kg / kKgPerLb;

double round1(double value) => (value * 10).roundToDouble() / 10;

/// Total centimetres from feet and inches.
double feetInchesToCm(int feet, double inches) => (feet * 12 + inches) * kCmPerInch;

/// Splits centimetres into whole feet and inches (one decimal), carrying 12 inches up to a foot.
({int feet, double inches}) cmToFeetInches(double cm) {
  final totalInches = cm / kCmPerInch;
  var feet = totalInches ~/ 12;
  var inches = round1(totalInches - feet * 12);
  if (inches >= 12) {
    feet += 1;
    inches = 0;
  }
  return (feet: feet, inches: inches);
}

String _trim(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

String formatWeight(double kg, UnitSystem system) =>
    system == UnitSystem.imperial ? '${_trim(round1(kgToLb(kg)))} lb' : '${_trim(round1(kg))} kg';

String formatHeight(double cm, UnitSystem system) {
  if (system == UnitSystem.metric) return '${_trim(round1(cm))} cm';
  final parts = cmToFeetInches(cm);
  return '${parts.feet} ft ${_trim(parts.inches)} in';
}

/// Parses a user-typed decimal. Accepts a comma as the decimal separator. Null when not a number.
double? parseDecimal(String? text) {
  final cleaned = (text ?? '').trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  return value != null && value.isFinite ? value : null;
}
