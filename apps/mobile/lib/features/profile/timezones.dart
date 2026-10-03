/// IANA timezones offered in the profile form. A curated, provisional list (docs/decisions.md D-020)
/// because the app has no timezone database dependency; the server accepts any valid IANA name, and
/// a stored value outside this list is still shown. The first entry is the default market.
const List<String> commonTimezones = [
  'Asia/Kolkata',
  'UTC',
  'Asia/Dubai',
  'Asia/Karachi',
  'Asia/Dhaka',
  'Asia/Colombo',
  'Asia/Kathmandu',
  'Asia/Bangkok',
  'Asia/Singapore',
  'Asia/Hong_Kong',
  'Asia/Tokyo',
  'Australia/Sydney',
  'Pacific/Auckland',
  'Europe/London',
  'Europe/Paris',
  'Europe/Berlin',
  'Europe/Moscow',
  'Africa/Cairo',
  'Africa/Johannesburg',
  'Africa/Lagos',
  'America/Sao_Paulo',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/Toronto',
];

/// A confident suggestion from the device's UTC offset, or null. Only offsets that map to one
/// timezone without daylight saving are suggested; anything else asks the user to choose.
String? suggestTimezone(Duration offset) {
  if (offset == const Duration(hours: 5, minutes: 30)) return 'Asia/Kolkata';
  return null;
}
