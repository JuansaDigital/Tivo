import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../main_layout/main_navigation_shell.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = '';
  final String _correctPin = '1234';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Do NOT auto-trigger biometrics on cold start to prevent unwanted system dialog popups.
  }

  Future<void> _authenticate() async {
    try {
      setState(() => _isAuthenticating = true);
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para acceder a tu panel de TIVO',
        biometricOnly: false,
      );
      setState(() => _isAuthenticating = false);
      if (authenticated && mounted) {
        _unlock();
      }
    } catch (e) {
      setState(() => _isAuthenticating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usa tu PIN (1234) para ingresar'),
            backgroundColor: TivoColors.statusWarningAmber,
          ),
        );
      }
    }
  }

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        if (_pin == _correctPin) {
          _unlock();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN incorrecto. (Usa 1234)'),
              backgroundColor: TivoColors.statusExpenseRose,
              duration: Duration(seconds: 2),
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
    return Scaffold(
      backgroundColor: const Color(0xFF070E22),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: TivoColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
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
            const Text(
              'Ingresa tu PIN de Seguridad',
              style: TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PIN predeterminado: 1234',
              style: TextStyle(
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
            _buildKeypad(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
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
                LucideIcons.scanFace,
                _isAuthenticating ? null : _authenticate,
                tooltip: 'Face ID / Huella',
              ),
              _buildKey('0'),
              _buildIconButton(
                LucideIcons.delete,
                _onDeleteTap,
                tooltip: 'Borrar',
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
