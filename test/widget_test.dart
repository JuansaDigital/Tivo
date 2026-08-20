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
    expect(find.text('Comenzar / Crear Perfil'), findsOneWidget);
    expect(find.text('Control Total y Sincronizado'), findsOneWidget);

    // Tap to open onboarding profile screen
    await tester.ensureVisible(find.text('Comenzar / Crear Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar / Crear Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido a TIVO!'), findsOneWidget);
    expect(find.text('ELIGE TU ÍCONO DE FINANZAS'), findsOneWidget);
  });
}

