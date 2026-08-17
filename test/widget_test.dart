import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivo/main.dart';

void main() {
  testWidgets('TivoApp smoke test - PRD Modules', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TivoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('BALANCE TOTAL NETO'), findsOneWidget);
    expect(find.text('Mis Instrumentos & Cuentas'), findsOneWidget);
    expect(find.text('Flujo de Caja Semanal'), findsOneWidget);
  });
}
