/// Privacy-conscious analytics/crash reporting (blueprint §18, M10).
///
/// This is a mock-first adapter, the same shape as every other provider boundary in the app
/// (`AuthRepository`, `MealScanRepository`, ...): callers depend only on this interface, never on a
/// concrete analytics SDK, so no vendor-specific type ever appears in feature code.
///
/// Hard rule enforced by this interface's shape, not just by convention: an event is a short,
/// pre-declared NAME plus a flat map of COARSE properties (counts, booleans, enum-like strings,
/// durations). There is no "attach arbitrary payload" method, so a caller cannot accidentally pass a
/// meal photo, a chat message, a diagnosis/eligibility answer, an email, or any other PII/health
/// content through this API even by mistake — the type signature itself is the safeguard. Reviewers
/// adding a new call site should still sanity-check the property values they pass, but the surface
/// area for a leak is a `Map<String, Object?>` of primitives, not a free-form payload.
library;

enum TelemetryEvent {
  appOpened,
  signInSucceeded,
  onboardingCompleted,
  mealScanSubmitted,
  mealScanQuotaReached,
  coachMessageSent,
  coachQuotaReached,
  dietPlanGenerated,
  workoutPlanGenerated,
  reminderOptedIn,
  reminderOptedOut,
  restorePurchasesTapped,
  entitlementUnlocked,
  accountExportRequested,
  accountDeletionRequested,
  errorShown,
}

/// A crash/non-fatal error report. [message] must already be a short, redacted summary (an error
/// code or exception type name) — never a raw exception message, which can embed request bodies.
class TelemetryError {
  const TelemetryError({required this.summary, this.properties = const {}});

  final String summary;
  final Map<String, Object?> properties;
}

abstract interface class TelemetryProvider {
  /// Opt-in state; when false every method below is a no-op. Defaults to false until the user
  /// consents (blueprint §18: analytics is opt-in, not opt-out).
  bool get enabled;

  Future<void> setEnabled(bool enabled);

  void logEvent(TelemetryEvent event, [Map<String, Object?> properties]);

  void logError(TelemetryError error);
}

/// Development/test default: records events in memory for assertions, never sends anything over the
/// network. This is also what a production build falls back to if analytics consent has not yet been
/// granted, which is why it is the safe default rather than a throwing stub.
class MockTelemetryProvider implements TelemetryProvider {
  MockTelemetryProvider({this.enabled = false});

  @override
  bool enabled;
  final List<(TelemetryEvent, Map<String, Object?>)> events = [];
  final List<TelemetryError> errors = [];

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  void logEvent(TelemetryEvent event, [Map<String, Object?> properties = const {}]) {
    if (!enabled) return;
    events.add((event, properties));
  }

  @override
  void logError(TelemetryError error) {
    if (!enabled) return;
    errors.add(error);
  }
}
