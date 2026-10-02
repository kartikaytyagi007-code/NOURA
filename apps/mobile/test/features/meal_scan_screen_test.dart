import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/meals/meal_scan_repository.dart';

import '../support/harness.dart';

void main() {
  testWidgets('Meals tab offers meal scanning and opens the capture screen', (tester) async {
    await pumpNoura(
      tester,
      auth: RecordingAuthRepository(initial: signedIn),
      profiles: FakeProfileRepository(),
      mealScan: MockMealScanRepository(),
    );

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    expect(find.text('Scan a meal'), findsOneWidget);

    await tester.tap(find.text('Scan a meal'));
    await tester.pumpAndSettle();

    expect(find.text('Take or choose a photo of your meal'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
  });
}
