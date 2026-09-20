import 'support/bootstrap_test_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';

void main() {
  testWidgets('App renders DashboardScreen inside ApplicationShell correctly', (
    tester,
  ) async {
    final bootstrap = await bootstrapForTest(initialLocation: '/dashboard');
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pump();

    expect(find.text('NexaBiz Dashboard'), findsOneWidget);
    expect(find.text('Welcome back to NexaBiz ERP'), findsOneWidget);
  });
}
