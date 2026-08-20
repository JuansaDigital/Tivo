import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/providers/security_provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/tivo_theme.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  await StorageService.init();

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
      navigatorKey: rootNavigatorKey,
      title: 'Tivo — Ecosistema Financiero Inteligente',
      debugShowCheckedModeBanner: false,
      theme: TivoTheme.darkTheme,
      home: const AppLifecycleWatcher(
        child: WelcomeScreen(),
      ),
    );
  }
}

class AppLifecycleWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleWatcher({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleWatcher> createState() => _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends ConsumerState<AppLifecycleWatcher> with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!);
        _pausedAt = null;
        _checkAndTriggerAutoLock(elapsed);
      }
    }
  }

  void _checkAndTriggerAutoLock(Duration elapsed) {
    final autoLockSetting = ref.read(autoLockProvider);

    bool shouldLock = false;
    switch (autoLockSetting) {
      case 'Inmediato':
        shouldLock = true;
        break;
      case '1 minuto':
        shouldLock = elapsed.inSeconds >= 60;
        break;
      case '5 minutos':
        shouldLock = elapsed.inSeconds >= 300;
        break;
      case 'Nunca':
      default:
        shouldLock = false;
        break;
    }

    if (shouldLock) {
      final navContext = rootNavigatorKey.currentContext;
      if (navContext != null) {
        final modalRoute = ModalRoute.of(navContext);
        final currentRouteName = modalRoute?.settings.name;

        // Evitar duplicar la pantalla de bloqueo si ya está en ella
        if (currentRouteName != '/lock') {
          rootNavigatorKey.currentState?.push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/lock'),
              builder: (_) => const LockScreen(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

