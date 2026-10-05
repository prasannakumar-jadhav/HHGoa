import 'package:flutter_test/flutter_test.dart';
import 'package:voxpilot/main.dart';

void main() {
  testWidgets('VoxPilot dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VoxPilotApp());
    await tester.pumpAndSettle();

    expect(find.text('VoxPilot'), findsOneWidget);
  });
}
