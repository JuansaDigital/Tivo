import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/widgets/tivo_button.dart';
import '../../main_layout/main_navigation_shell.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedAvatarId = 'wallet';
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _selectedAvatarId = profile.avatarIconId;
    _selectedColorIndex = profile.avatarColorIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(userProfileProvider.notifier).completeProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatarIconId: _selectedAvatarId,
        avatarColorIndex: _selectedColorIndex,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = UserProfileModel.avatarGradients[_selectedColorIndex];
    final selectedOption = UserProfileModel.availableAvatars.firstWhere(
      (a) => a.id == _selectedAvatarId,
      orElse: () => UserProfileModel.availableAvatars.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070E22),
      body: Stack(
        children: [
          // Background ambient gradient orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentGradient.first.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button if applicable
                    if (Navigator.of(context).canPop())
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft, color: TivoColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    const SizedBox(height: 8),

                    // Title
                    const Text(
                      '¡Bienvenido a TIVO!',
                      style: TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Crea tu perfil financiero para personalizar tu panel y seguimiento patrimonial.',
                      style: TextStyle(
                        color: TivoColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Live Avatar Preview Badge
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: currentGradient.first.withOpacity(0.4),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: currentGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              selectedOption.icon,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        selectedOption.label,
                        style: TextStyle(
                          color: currentGradient.first,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector de Ícono Financiero
                    const Text(
                      'ELIGE TU ÍCONO DE FINANZAS',
                      style: TextStyle(
                        color: TivoColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 85,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: UserProfileModel.availableAvatars.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final option = UserProfileModel.availableAvatars[index];
                          final isSelected = _selectedAvatarId == option.id;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatarId = option.id),
                            child: Container(
                              width: 72,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                                    size: 24,
                                    color: isSelected ? currentGradient.first : TivoColors.textSecondary,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : TivoColors.textTertiary,
                                      fontSize: 10,
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
                    const SizedBox(height: 18),

                    // Selector de Color / Gradiente
                    const Text(
                      'COLOR DE DISTINTIVO',
                      style: TextStyle(
                        color: TivoColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(UserProfileModel.avatarGradients.length, (index) {
                        final isSelected = _selectedColorIndex == index;
                        final grad = UserProfileModel.avatarGradients[index];

                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = index),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: grad,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: grad.first.withOpacity(0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(LucideIcons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),

                    // Campo de Nombre
                    const Text(
                      'TU NOMBRE O ALIAS',
                      style: TextStyle(
                        color: TivoColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 15),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Ej: Juan Salinas, Camila...',
                        hintStyle: const TextStyle(color: TivoColors.textTertiary),
                        prefixIcon: const Icon(LucideIcons.user, color: TivoColors.textTertiary, size: 18),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: BorderSide(color: currentGradient.first, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Campo de Correo
                    const Text(
                      'CORREO ELECTRÓNICO',
                      style: TextStyle(
                        color: TivoColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 15),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Ej: usuario@tivo.app',
                        hintStyle: const TextStyle(color: TivoColors.textTertiary),
                        prefixIcon: const Icon(LucideIcons.mail, color: TivoColors.textTertiary, size: 18),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          borderSide: BorderSide(color: currentGradient.first, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón Continuar
                    TivoButton(
                      width: double.infinity,
                      label: 'Comenzar mi Experiencia TIVO',
                      icon: LucideIcons.arrowRight,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
