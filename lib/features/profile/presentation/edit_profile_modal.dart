import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/widgets/tivo_button.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  const EditProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedAvatarId;
  late int _selectedColorIndex;

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

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(userProfileProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatarIconId: _selectedAvatarId,
        avatarColorIndex: _selectedColorIndex,
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
          backgroundColor: TivoColors.statusIncomeGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentGradient = UserProfileModel.avatarGradients[_selectedColorIndex];
    final selectedOption = UserProfileModel.availableAvatars.firstWhere(
      (a) => a.id == _selectedAvatarId,
      orElse: () => UserProfileModel.availableAvatars.first,
    );

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: TivoColors.bgDeepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(TivoSpacing.radiusXl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Editar Perfil Financiero',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Vista previa del Avatar
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: currentGradient.first.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 76,
                      height: 76,
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
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  selectedOption.label,
                  style: TextStyle(
                    color: currentGradient.first,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Selector de Ícono
              const Text(
                'ÍCONO DE FINANZAS',
                style: TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
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

              // Selector de Color
              const Text(
                'COLOR DE DISTINTIVO',
                style: TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(UserProfileModel.avatarGradients.length, (index) {
                  final isSelected = _selectedColorIndex == index;
                  final grad = UserProfileModel.avatarGradients[index];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 40,
                      height: 40,
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
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: grad.first.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(LucideIcons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Nombre
              const Text(
                'NOMBRE O ALIAS',
                style: TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ej: Juan Salinas',
                  hintStyle: const TextStyle(color: TivoColors.textTertiary),
                  prefixIcon: const Icon(LucideIcons.user, color: TivoColors.textTertiary, size: 16),
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
              const SizedBox(height: 14),

              // Correo
              const Text(
                'CORREO ELECTRÓNICO',
                style: TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14),
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
                  hintText: 'Ej: juan@tivo.app',
                  hintStyle: const TextStyle(color: TivoColors.textTertiary),
                  prefixIcon: const Icon(LucideIcons.mail, color: TivoColors.textTertiary, size: 16),
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
              const SizedBox(height: 24),

              // Botón Guardar
              TivoButton(
                width: double.infinity,
                label: 'Guardar Perfil',
                icon: LucideIcons.save,
                onPressed: _save,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
