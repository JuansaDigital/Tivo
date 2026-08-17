import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/tivo_theme.dart';
import 'features/auth/presentation/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar barra de estado transparente y estilo oscuro
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: TivoApp(),
    ),
  );
}

class TivoApp extends StatelessWidget {
  const TivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tivo — Ecosistema Financiero Inteligente',
      debugShowCheckedModeBanner: false,
      theme: TivoTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}
