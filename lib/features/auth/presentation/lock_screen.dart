import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/security_provider.dart';
import '../../main_layout/main_navigation_shell.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = '';
  bool _isAuthenticating = false;
  bool _isFaceId = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricsSupport();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isBiometricEnabled = ref.read(biometricEnabledProvider);
      if (isBiometricEnabled) {
        _authenticate();
      }
    });
  }

  Future<void> _checkBiometricsSupport() async {
    try {
      final biometrics = await auth.getAvailableBiometrics();
      if (mounted) {
        setState(() {
          _isFaceId = biometrics.contains(BiometricType.face);
        });
      }
    } catch (_) {
      // Ignorar fallback
    }
  }

  Future<void> _authenticate() async {
    final isBiometricEnabled = ref.read(biometricEnabledProvider);
    final strings = ref.read(stringsProvider);

    if (!isBiometricEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings['lock_biometric_disabled'] ?? 'El acceso biométrico está desactivado en Configuraciones.'),
            backgroundColor: TivoColors.statusWarningAmber,
          ),
        );
      }
      return;
    }

    try {
      setState(() => _isAuthenticating = true);
      final bool authenticated = await auth.authenticate(
        localizedReason: strings['lock_biometric_reason'] ?? 'Autentícate para acceder a tu panel de TIVO',
        biometricOnly: false,
      );
      if (mounted) {
        setState(() => _isAuthenticating = false);
        if (authenticated) {
          _unlock();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings['lock_biometric_fallback'] ?? 'Usa tu PIN de seguridad para ingresar'),
            backgroundColor: TivoColors.statusWarningAmber,
          ),
        );
      }
    }
  }

  void _onKeypadTap(String value) {
    final correctPin = ref.read(userPinProvider);
    final strings = ref.read(stringsProvider);

    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        if (_pin == correctPin) {
          _unlock();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings['lock_pin_wrong'] ?? 'PIN incorrecto.'),
              backgroundColor: TivoColors.statusExpenseRose,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() => _pin = '');
        }
      }
    }
  }

  void _onDeleteTap() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _unlock() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final userPin = ref.watch(userPinProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070E22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: TivoColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TivoColors.primaryIceBlue.withOpacity(0.12),
                border: Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.3)),
              ),
              child: const Icon(
                LucideIcons.lock,
                size: 40,
                color: TivoColors.primaryIceBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings['lock_title'] ?? 'Ingresa tu PIN de Seguridad',
              style: const TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${strings['lock_subtitle'] ?? 'PIN predeterminado:'} $userPin',
              style: const TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = _pin.length > index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: isFilled ? 18 : 14,
                  height: isFilled ? 18 : 14,
                  decoration: BoxDecoration(
                    color: isFilled ? TivoColors.accentElectricCyan : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilled ? TivoColors.accentElectricCyan : Colors.white24,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: TivoColors.accentElectricCyan.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildKeypad(strings),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(Map<String, String> strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKey('1'), _buildKey('2'), _buildKey('3'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKey('4'), _buildKey('5'), _buildKey('6'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKey('7'), _buildKey('8'), _buildKey('9'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(
                _isFaceId ? LucideIcons.scanFace : LucideIcons.fingerprint,
                _isAuthenticating ? null : _authenticate,
                tooltip: strings['lock_biometric_btn'] ?? 'Face ID / Huella',
              ),
              _buildKey('0'),
              _buildIconButton(
                LucideIcons.delete,
                _onDeleteTap,
                tooltip: strings['lock_delete_btn'] ?? 'Borrar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeypadTap(value),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: TivoColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap, {String? tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: TivoColors.primaryIceBlue, size: 26),
        ),
      ),
    );
  }
}

