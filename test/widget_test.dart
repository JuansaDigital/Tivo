import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tivo/core/services/storage_service.dart';
import 'package:tivo/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('TivoApp smoke test - Welcome and Branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TivoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TIVO'), findsOneWidget);
    expect(find.text('Crear Cuenta / Comenzar'), findsOneWidget);
    expect(find.text('Control Total y Sincronizado'), findsOneWidget);

    // Tap to open auth screen in sign up mode
    await tester.ensureVisible(find.text('Crear Cuenta / Comenzar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear Cuenta / Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('Crear Cuenta en TIVO'), findsOneWidget);
    expect(find.text('ELIGE TU ÍCONO DE FINANZAS'), findsOneWidget);
  });
}

