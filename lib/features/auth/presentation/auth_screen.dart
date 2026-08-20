import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/providers/auth_provider.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de autenticación: $e'),
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
                    const SizedBox(height: 28),

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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
