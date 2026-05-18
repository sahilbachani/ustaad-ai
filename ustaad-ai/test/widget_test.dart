import 'package:flutter_test/flutter_test.dart';
import 'package:ustaad_ai/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: UstaadApp()),
    );
    // Verify app title renders
    expect(find.text('Ustaad'), findsOneWidget);
    expect(find.text('.ai'), findsOneWidget);
  });
}
