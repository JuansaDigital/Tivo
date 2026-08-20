import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/tivo_button.dart';
import '../../main_layout/main_navigation_shell.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({super.key, this.initialIsSignUp = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isSignUp;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String _selectedAvatarId = 'wallet';
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al autenticar con Google: $e'),
            backgroundColor: TivoColors.statusExpenseRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await ref.read(authStateProvider.notifier).signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          avatarIconId: _selectedAvatarId,
          avatarColorIndex: _selectedColorIndex,
        );
        if (_pinController.text.trim().isNotEmpty) {
          ref.read(userPinProvider.notifier).updatePin(_pinController.text.trim());
        }
      } else {
        await ref.read(authStateProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceAll('Exception: ', '').replaceAll('FirebaseAuthException: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMsg),
            backgroundColor: TivoColors.statusExpenseRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = UserProfileModel.avatarGradients[_selectedColorIndex];

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
      body: Stack(
        children: [
          // Background ambient gradient orb
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TivoColors.primaryIceBlue.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand / Title
                    Text(
                      _isSignUp ? 'Crear Cuenta en TIVO' : 'Bienvenido de Vuelta',
                      style: const TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUp
                          ? 'Regístrate para guardar y sincronizar tu patrimonio'
                          : 'Ingresa para acceder a tus finanzas y métricas',
                      style: const TextStyle(
                        color: TivoColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab selector (Iniciar Sesión vs Crear Cuenta)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isSignUp ? TivoColors.primaryIceBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                                ),
                                child: Center(
                                  child: Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      color: !_isSignUp ? const Color(0xFF070E22) : TivoColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isSignUp ? TivoColors.primaryIceBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                                ),
                                child: Center(
                                  child: Text(
                                    'Crear Cuenta',
                                    style: TextStyle(
                                      color: _isSignUp ? const Color(0xFF070E22) : TivoColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de Google Sign-In
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      borderRadius: TivoSpacing.radiusLg,
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Color(0xFFEA4335),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continuar con Google',
                            style: TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divisor
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white10)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o con correo electrónico',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white10)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Si es registro: Selector de Ícono Financiero
                    if (_isSignUp) ...[
                      const Text('ELIGE TU ÍCONO DE FINANZAS', style: _labelStyle),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 75,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: UserProfileModel.availableAvatars.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final option = UserProfileModel.availableAvatars[index];
                            final isSelected = _selectedAvatarId == option.id;

                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatarId = option.id),
                              child: Container(
                                width: 68,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? currentGradient.first.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                                  border: Border.all(
                                    color: isSelected ? currentGradient.first : Colors.white10,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 20,
                                      color: isSelected ? currentGradient.first : TivoColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option.label,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : TivoColors.textTertiary,
                                        fontSize: 9,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('COLOR DE DISTINTIVO', style: _labelStyle),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(UserProfileModel.avatarGradients.length, (index) {
                          final isSelected = _selectedColorIndex == index;
                          final grad = UserProfileModel.avatarGradients[index];

                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: grad,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      const Text('TU NOMBRE O ALIAS', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                        decoration: _inputDecoration('Ej: Juan Salinas', LucideIcons.user),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Correo Electrónico
                    const Text('CORREO ELECTRÓNICO', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                        if (!val.contains('@') || !val.contains('.')) return 'Correo inválido';
                        return null;
                      },
                      decoration: _inputDecoration('Ej: usuario@tivo.app', LucideIcons.mail),
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    const Text('CONTRASEÑA', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Ingresa tu contraseña';
                        if (val.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: TivoColors.textTertiary),
                        prefixIcon: const Icon(LucideIcons.lock, color: TivoColors.textTertiary, size: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: TivoColors.textTertiary,
                            size: 16,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: const BorderSide(color: TivoColors.primaryIceBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isSignUp) ...[
                      const Text('PIN DE SEGURIDAD (4 DÍGITOS)', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14, letterSpacing: 4),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Ingresa tu PIN de 4 dígitos';
                          if (val.trim().length != 4 || int.tryParse(val.trim()) == null) {
                            return 'El PIN debe ser de exactamente 4 números';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••',
                          hintStyle: const TextStyle(color: TivoColors.textTertiary, letterSpacing: 4),
                          prefixIcon: const Icon(LucideIcons.keyRound, color: TivoColors.textTertiary, size: 16),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            borderSide: const BorderSide(color: TivoColors.primaryIceBlue, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('CONFIRMAR PIN (4 DÍGITOS)', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14, letterSpacing: 4),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Confirma tu PIN';
                          if (val.trim() != _pinController.text.trim()) {
                            return 'Los PINs no coinciden';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••',
                          hintStyle: const TextStyle(color: TivoColors.textTertiary, letterSpacing: 4),
                          prefixIcon: const Icon(LucideIcons.shieldCheck, color: TivoColors.textTertiary, size: 16),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            borderSide: const BorderSide(color: TivoColors.primaryIceBlue, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 12),

                    // Botón Principal
                    TivoButton(
                      width: double.infinity,
                      label: _isLoading
                          ? 'Procesando...'
                          : _isSignUp
                              ? 'Crear Cuenta'
                              : 'Iniciar Sesión',
                      icon: _isSignUp ? LucideIcons.userPlus : LucideIcons.logIn,
                      onPressed: _isLoading ? () {} : _handleSubmit,
                    ),
                    const SizedBox(height: 16),

                    // Aviso legal de Política de Privacidad
                    GestureDetector(
                      onTap: () => _showPrivacyPolicyModal(context),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                              children: [
                                TextSpan(text: 'Al continuar declaras que aceptas la '),
                                TextSpan(
                                  text: 'Política de Privacidad y Términos',
                                  style: TextStyle(
                                    color: TivoColors.primaryIceBlue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' de TIVO.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D152D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: const Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: TivoColors.primaryIceBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Política de Privacidad',
                style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cumplimiento de Políticas de Privacidad (App Store & Google Play):\n\n'
                  '1. Privacidad de Datos: TIVO no rastrea ni vende tus datos financieros ni personales a anunciantes o terceros.\n\n'
                  '2. Protección & Cifrado: Tus credenciales y código PIN se almacenan mediante cifrado seguro en tu dispositivo.\n\n'
                  '3. Derecho de Eliminación: Puedes eliminar permanentemente tu cuenta y todos tus datos guardados en cualquier momento desde la sección de Configuraciones.',
                  style: TextStyle(color: TivoColors.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: TivoColors.primaryIceBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: TivoColors.textTertiary),
      prefixIcon: Icon(icon, color: TivoColors.textTertiary, size: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
        borderSide: const BorderSide(color: TivoColors.primaryIceBlue, width: 1.5),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  color: TivoColors.textTertiary,
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.0,
);
