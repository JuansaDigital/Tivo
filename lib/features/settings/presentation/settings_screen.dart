import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../accounts/data/account_provider.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../budgets/data/budget_provider.dart';
import '../../dashboard/data/metrics_provider.dart';
import '../../profile/presentation/edit_profile_modal.dart';
import '../../reminders/data/reminders_provider.dart';
import '../../savings/data/savings_provider.dart';
import '../../shared_finances/data/split_bill_provider.dart';
import '../../transactions/data/transaction_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppLanguage? _selectedLanguage;
  Currency? _selectedCurrency;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _selectedLanguage = ref.read(languageProvider);
      _selectedCurrency = ref.read(currencyProvider);
      _isInitialized = true;
    }
  }

  void _savePreferences(Map<String, String> strings) {
    if (_selectedLanguage != null) {
      ref.read(languageProvider.notifier).setLanguage(_selectedLanguage!);
    }
    if (_selectedCurrency != null) {
      ref.read(currencyProvider.notifier).setCurrency(_selectedCurrency!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: TivoColors.statusIncomeGreenLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings['preferences_saved_msg'] ?? '¡Preferencias guardadas exitosamente! ✨',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: TivoColors.bgNavyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
          side: const BorderSide(color: TivoColors.statusIncomeGreen, width: 1),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, Map<String, String> strings) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final currentStoredPin = ref.read(userPinProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TivoColors.bgDeepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.keyRound, color: TivoColors.primaryIceBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                strings['change_pin'] ?? 'Cambiar PIN de Acceso',
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPinField(
                  controller: currentPinController,
                  label: strings['current_pin_label'] ?? 'PIN Actual',
                  hint: '••••',
                ),
                const SizedBox(height: 12),
                _buildPinField(
                  controller: newPinController,
                  label: strings['new_pin_label'] ?? 'Nuevo PIN (4 dígitos)',
                  hint: '••••',
                ),
                const SizedBox(height: 12),
                _buildPinField(
                  controller: confirmPinController,
                  label: strings['confirm_pin_label'] ?? 'Confirmar Nuevo PIN',
                  hint: '••••',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings['cancel'] ?? 'Cancelar', style: const TextStyle(color: TivoColors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                final current = currentPinController.text.trim();
                final newPin = newPinController.text.trim();
                final confirm = confirmPinController.text.trim();

                if (current != currentStoredPin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings['pin_mismatch_current'] ?? 'El PIN actual no coincide.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                if (newPin.length != 4 || int.tryParse(newPin) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings['pin_invalid_length'] ?? 'El nuevo PIN debe tener exactamente 4 dígitos numéricos.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                if (newPin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings['pin_mismatch_new'] ?? 'Los nuevos PINs no coinciden.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                ref.read(userPinProvider.notifier).updatePin(newPin);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings['pin_success_updated'] ?? '¡PIN actualizado correctamente! 🔒'),
                    backgroundColor: TivoColors.statusIncomeGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.primaryIceBlue,
                foregroundColor: const Color(0xFF070E22),
              ),
              child: Text(strings['save_pin_btn'] ?? 'Guardar PIN', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: TivoColors.textPrimary, fontSize: 16, letterSpacing: 4),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(color: TivoColors.textTertiary),
            filled: true,
            fillColor: Colors.black.withOpacity(0.25),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: const BorderSide(color: TivoColors.primaryIceBlue),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDataConfirmation(BuildContext context, Map<String, String> strings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TivoColors.bgDeepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            strings['delete_dialog_title'] ?? 'Borrar todos los datos',
            style: const TextStyle(color: TivoColors.statusExpenseRoseLight, fontWeight: FontWeight.bold),
          ),
          content: Text(
            strings['delete_dialog_desc'] ??
                '¿Estás seguro de que deseas eliminar permanentemente todas tus cuentas, números, ingresos, gastos, presupuestos y metas? Esta acción dejará la app en 0.',
            style: const TextStyle(color: TivoColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings['cancel'] ?? 'Cancelar', style: const TextStyle(color: TivoColors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                // Wipe all financial data 100%
                ref.read(accountListProvider.notifier).reset();
                ref.read(transactionListProvider.notifier).reset();
                ref.read(reminderListProvider.notifier).reset();
                ref.read(savingsListProvider.notifier).reset();
                ref.read(budgetListProvider.notifier).reset();
                ref.read(splitBillListProvider.notifier).reset();
                ref.read(userProfileProvider.notifier).reset();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings['delete_success_msg'] ?? 'Toda la información financiera ha sido borrada con éxito (\$0).'),
                    backgroundColor: TivoColors.statusExpenseRose,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.statusExpenseRose,
                foregroundColor: Colors.white,
              ),
              child: Text(strings['delete_confirm_btn'] ?? 'Eliminar Todo', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TivoColors.bgDeepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: TivoColors.statusExpenseRose, size: 22),
              SizedBox(width: 8),
              Text(
                'Eliminar Cuenta',
                style: TextStyle(color: TivoColors.statusExpenseRoseLight, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            '¿Estás completamente seguro de que deseas eliminar tu cuenta?\n\nEsta acción es irreversible y borrará de inmediato tu sesión, correo, credenciales y todos los registros financieros de cuentas, transacciones y metas.',
            style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: TivoColors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).deleteAccount();
                ref.read(userPinProvider.notifier).updatePin('');
                ref.read(userProfileProvider.notifier).reset();
                ref.read(accountListProvider.notifier).reset();
                ref.read(transactionListProvider.notifier).reset();
                ref.read(reminderListProvider.notifier).reset();
                ref.read(savingsListProvider.notifier).reset();
                ref.read(budgetListProvider.notifier).reset();
                ref.read(splitBillListProvider.notifier).reset();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: true)),
                    (route) => false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tu cuenta ha sido eliminada permanentemente. Por favor crea una nueva cuenta.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.statusExpenseRose,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, Eliminar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isBiometric = ref.watch(biometricEnabledProvider);
    final userPin = ref.watch(userPinProvider);
    final isPrivacy = ref.watch(privacyModeProvider);
    final autoLock = ref.watch(autoLockProvider);

    final currentLang = _selectedLanguage ?? ref.watch(languageProvider);
    final currentCurr = _selectedCurrency ?? ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: TivoColors.bgDeepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: TivoColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['settings_title'] ?? 'Configuraciones',
          style: const TextStyle(
            color: TivoColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. User Profile Section
            Consumer(
              builder: (context, ref, _) {
                final profile = ref.watch(userProfileProvider);
                final displayName = profile.name.isNotEmpty ? profile.name : 'Configurar Perfil';
                final displayEmail = profile.email.isNotEmpty ? profile.email : 'Toca para personalizar tu cuenta';

                return GlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: TivoSpacing.radiusLg,
                  onTap: () => EditProfileModal.show(context),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: profile.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: profile.gradientColors.first.withOpacity(0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            profile.iconData,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: TivoColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayEmail,
                              style: const TextStyle(
                                color: TivoColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TivoColors.primaryIceBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                          border: Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.pencil, size: 12, color: TivoColors.primaryIceBlue),
                            SizedBox(width: 4),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: TivoColors.primaryIceBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 2. Seguridad y Privacidad Section
            Text(
              strings['security_privacy'] ?? 'Seguridad y Privacidad',
              style: const TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: TivoSpacing.radiusLg,
              child: Column(
                children: [
                  // Login Biométrico Toggle
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.scanFace, color: TivoColors.primaryIceBlue),
                    title: Text(strings['biometric_login'] ?? 'Login Biométrico', style: const TextStyle(color: TivoColors.textPrimary)),
                    subtitle: Text(strings['biometric_login_desc'] ?? 'Permitir acceso rápido con datos biométricos', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    value: isBiometric,
                    activeColor: TivoColors.primaryIceBlue,
                    onChanged: (val) {
                      ref.read(biometricEnabledProvider.notifier).toggle(val);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),

                  // Cambiar PIN
                  ListTile(
                    leading: const Icon(LucideIcons.keyRound, color: TivoColors.primaryIceBlue),
                    title: Text(strings['change_pin'] ?? 'Cambiar PIN de Acceso', style: const TextStyle(color: TivoColors.textPrimary)),
                    subtitle: Text('${strings['change_pin_desc'] ?? 'PIN actual configurado:'} $userPin', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    trailing: const Icon(LucideIcons.chevronRight, color: TivoColors.textSecondary, size: 18),
                    onTap: () => _showChangePinDialog(context, strings),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),

                  // Modo Oculto / Privacidad (Ocultar Saldos)
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.eyeOff, color: TivoColors.accentElectricCyan),
                    title: Text(strings['privacy_mode'] ?? 'Modo Oculto / Privacidad', style: const TextStyle(color: TivoColors.textPrimary)),
                    subtitle: Text(strings['privacy_mode_desc'] ?? 'Ocultar montos y balances sensibles (••••••)', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    value: isPrivacy,
                    activeColor: TivoColors.accentElectricCyan,
                    onChanged: (val) {
                      ref.read(privacyModeProvider.notifier).state = val;
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),

                  // Bloqueo Automático
                  ListTile(
                    leading: const Icon(LucideIcons.timer, color: TivoColors.primaryIceBlue),
                    title: Text(strings['auto_lock'] ?? 'Bloqueo Automático', style: const TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: autoLock,
                      dropdownColor: TivoColors.bgDeepNavy,
                      underline: const SizedBox(),
                      icon: const Icon(LucideIcons.chevronDown, color: TivoColors.textSecondary),
                      items: [
                        'Inmediato',
                        '1 minuto',
                        '5 minutos',
                        'Nunca',
                      ].map((opt) {
                        String displayOpt = opt;
                        if (opt == 'Inmediato') displayOpt = strings['auto_lock_immediate'] ?? opt;
                        if (opt == '1 minuto') displayOpt = strings['auto_lock_1min'] ?? opt;
                        if (opt == '5 minutos') displayOpt = strings['auto_lock_5min'] ?? opt;
                        if (opt == 'Nunca') displayOpt = strings['auto_lock_never'] ?? opt;

                        return DropdownMenuItem(
                          value: opt,
                          child: Text(displayOpt, style: const TextStyle(color: TivoColors.textSecondary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(autoLockProvider.notifier).setDuration(val);
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),

                  // Cerrar Sesión / Bloquear App
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: TivoColors.statusWarningAmber),
                    title: Text(strings['logout_lock'] ?? 'Bloquear / Cerrar Sesión', style: const TextStyle(color: TivoColors.textPrimary)),
                    subtitle: Text(strings['logout_lock_desc'] ?? 'Volver a la pantalla de bienvenida y bloqueo', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    trailing: const Icon(LucideIcons.chevronRight, color: TivoColors.textSecondary, size: 18),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Preferencias Section (con Botón de Guardado)
            Text(
              strings['preferences_section'] ?? 'Preferencias',
              style: const TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: TivoSpacing.radiusLg,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.globe, color: TivoColors.primaryIceBlue),
                    title: Text(strings['language'] ?? 'Idioma', style: const TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<AppLanguage>(
                      value: currentLang,
                      dropdownColor: TivoColors.bgDeepNavy,
                      underline: const SizedBox(),
                      icon: const Icon(LucideIcons.chevronDown, color: TivoColors.textSecondary),
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang.label,
                            style: const TextStyle(color: TivoColors.textSecondary),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedLanguage = val;
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.coins, color: TivoColors.primaryIceBlue),
                    title: Text(strings['main_currency'] ?? 'Moneda Principal', style: const TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<Currency>(
                      value: currentCurr,
                      dropdownColor: TivoColors.bgDeepNavy,
                      underline: const SizedBox(),
                      icon: const Icon(LucideIcons.chevronDown, color: TivoColors.textSecondary),
                      items: Currency.values.map((curr) {
                        return DropdownMenuItem(
                          value: curr,
                          child: Text(
                            curr.label,
                            style: const TextStyle(color: TivoColors.textSecondary),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de Guardado de Preferencias
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _savePreferences(strings),
                      icon: const Icon(LucideIcons.save, size: 18),
                      label: Text(
                        strings['save_preferences'] ?? 'Guardar Preferencias',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TivoColors.primaryIceBlue,
                        foregroundColor: const Color(0xFF070E22),
                        elevation: 4,
                        shadowColor: TivoColors.primaryIceBlue.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Gestión de Datos Section
            Text(
              strings['data_management'] ?? 'Gestión de Datos & Almacenamiento',
              style: const TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: TivoSpacing.radiusLg,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                    title: Text(
                      strings['delete_all'] ?? 'Borrar todos los datos (\$0)',
                      style: const TextStyle(
                        color: TivoColors.statusExpenseRoseLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(strings['delete_all_desc'] ?? 'Reiniciar la app limpia en \$0 para ingresar tus propios datos', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    onTap: () => _showDeleteDataConfirmation(context, strings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. Cuenta & Autenticación (Firebase / Google)
            const Text(
              'CUENTA & AUTENTICACIÓN',
              style: TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: TivoSpacing.radiusLg,
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final authUser = ref.watch(authStateProvider);
                      final isGoogle = authUser?.providerType == AuthProviderType.google;
                      final providerLabel = isGoogle
                          ? 'Conectado con Google'
                          : authUser != null
                              ? 'Cuenta de Correo'
                              : 'Sesión Local';

                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isGoogle
                                ? const Color(0xFFEA4335).withOpacity(0.15)
                                : TivoColors.primaryIceBlue.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: isGoogle
                              ? const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(0xFFEA4335),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                )
                              : const Icon(
                                  LucideIcons.userCheck,
                                  color: TivoColors.primaryIceBlue,
                                  size: 18,
                                ),
                        ),
                        title: Text(providerLabel, style: const TextStyle(color: TivoColors.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          authUser?.email.isNotEmpty == true ? authUser!.email : 'Sin sincronización en la nube',
                          style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: TivoColors.textSecondary),
                    title: const Text('Cerrar Sesión', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: const Text('Desconectar la sesión en este dispositivo', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(LucideIcons.userX, color: TivoColors.statusExpenseRose),
                    title: const Text(
                      'Eliminar Cuenta Permanentemente',
                      style: TextStyle(
                        color: TivoColors.statusExpenseRoseLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('Borrar perfil, credenciales y todos los datos financieros', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    onTap: () => _showDeleteAccountConfirmation(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

