import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../accounts/data/account_provider.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../budgets/data/budget_provider.dart';
import '../../dashboard/data/metrics_provider.dart';
import '../../reminders/data/reminders_provider.dart';
import '../../savings/data/savings_provider.dart';
import '../../shared_finances/data/split_bill_provider.dart';
import '../../transactions/data/transaction_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context, WidgetRef ref) {
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
            children: const [
              Icon(LucideIcons.keyRound, color: TivoColors.primaryIceBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Cambiar PIN de Acceso',
                style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPinField(
                  controller: currentPinController,
                  label: 'PIN Actual',
                  hint: '••••',
                ),
                const SizedBox(height: 12),
                _buildPinField(
                  controller: newPinController,
                  label: 'Nuevo PIN (4 dígitos)',
                  hint: '••••',
                ),
                const SizedBox(height: 12),
                _buildPinField(
                  controller: confirmPinController,
                  label: 'Confirmar Nuevo PIN',
                  hint: '••••',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: TivoColors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                final current = currentPinController.text.trim();
                final newPin = newPinController.text.trim();
                final confirm = confirmPinController.text.trim();

                if (current != currentStoredPin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El PIN actual no coincide.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                if (newPin.length != 4 || int.tryParse(newPin) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nuevo PIN debe tener exactamente 4 dígitos numéricos.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                if (newPin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Los nuevos PINs no coinciden.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                  return;
                }

                ref.read(userPinProvider.notifier).updatePin(newPin);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡PIN actualizado correctamente a $newPin! 🔒'),
                    backgroundColor: TivoColors.statusIncomeGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.primaryIceBlue,
                foregroundColor: const Color(0xFF070E22),
              ),
              child: const Text('Guardar PIN', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showDeleteDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TivoColors.bgDeepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: const Text(
            'Borrar todos los datos',
            style: TextStyle(color: TivoColors.statusExpenseRoseLight, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar permanentemente todas tus cuentas, números, ingresos, gastos, presupuestos y metas? Esta acción dejará la app en 0.',
            style: TextStyle(color: TivoColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: TivoColors.textTertiary)),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toda la información financiera ha sido borrada con éxito (\$0).'),
                    backgroundColor: TivoColors.statusExpenseRose,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.statusExpenseRose,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Todo', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBiometric = ref.watch(biometricEnabledProvider);
    final userPin = ref.watch(userPinProvider);
    final isPrivacy = ref.watch(privacyModeProvider);
    final autoLock = ref.watch(autoLockProvider);

    return Scaffold(
      backgroundColor: TivoColors.bgDeepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: TivoColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuraciones',
          style: TextStyle(
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
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: TivoSpacing.radiusLg,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [TivoColors.primaryIceBlue, TivoColors.accentElectricCyan],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TivoColors.primaryIceBlue.withOpacity(0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'JS',
                        style: TextStyle(
                          color: Color(0xFF070E22),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Juan Salinas',
                        style: TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'juan@tivo.app',
                        style: TextStyle(
                          color: TivoColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Seguridad y Privacidad Section
            const Text(
              'Seguridad y Privacidad',
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
                  // Login Biométrico Toggle
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.scanFace, color: TivoColors.primaryIceBlue),
                    title: const Text('Login Biométrico (Face ID)', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: const Text('Permitir acceso rápido con datos biométricos', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
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
                    title: const Text('Cambiar PIN de Acceso', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: Text('PIN actual configurado: $userPin', style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    trailing: const Icon(LucideIcons.chevronRight, color: TivoColors.textSecondary, size: 18),
                    onTap: () => _showChangePinDialog(context, ref),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),

                  // Modo Oculto / Privacidad (Ocultar Saldos)
                  SwitchListTile(
                    secondary: const Icon(LucideIcons.eyeOff, color: TivoColors.accentElectricCyan),
                    title: const Text('Modo Oculto / Privacidad', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: const Text('Ocultar montos y balances sensibles (••••••)', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
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
                    title: const Text('Bloqueo Automático', style: TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: autoLock,
                      dropdownColor: TivoColors.bgDeepNavy,
                      underline: const SizedBox(),
                      icon: const Icon(LucideIcons.chevronDown, color: TivoColors.textSecondary),
                      items: ['Inmediato', '1 minuto', '5 minutos', 'Nunca'].map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt, style: const TextStyle(color: TivoColors.textSecondary)),
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
                    title: const Text('Bloquear / Cerrar Sesión', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: const Text('Volver a la pantalla de bienvenida y bloqueo', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
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

            // 3. Preferencias Section
            const Text(
              'Preferencias',
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
                  ListTile(
                    leading: const Icon(LucideIcons.globe, color: TivoColors.primaryIceBlue),
                    title: const Text('Idioma', style: TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<AppLanguage>(
                      value: ref.watch(languageProvider),
                      dropdownColor: TivoColors.bgDeepNavy,
                      underline: const SizedBox(),
                      icon: const Icon(LucideIcons.chevronDown, color: TivoColors.textSecondary),
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang == AppLanguage.es ? 'Español' : 'English',
                            style: const TextStyle(color: TivoColors.textSecondary),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(languageProvider.notifier).setLanguage(val);
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(LucideIcons.coins, color: TivoColors.primaryIceBlue),
                    title: const Text('Moneda Principal', style: TextStyle(color: TivoColors.textPrimary)),
                    trailing: DropdownButton<Currency>(
                      value: ref.watch(currencyProvider),
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
                          ref.read(currencyProvider.notifier).setCurrency(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Gestión de Datos Section
            const Text(
              'Gestión de Datos & Almacenamiento',
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
                  ListTile(
                    leading: const Icon(LucideIcons.sparkles, color: TivoColors.primaryIceBlue),
                    title: const Text('Cargar Datos de Ejemplo (Demo)', style: TextStyle(color: TivoColors.textPrimary)),
                    subtitle: const Text('Poblar la app con datos financieros de demostración', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    onTap: () {
                      ref.read(accountListProvider.notifier).loadDemoData();
                      ref.read(transactionListProvider.notifier).loadDemoData();
                      ref.read(reminderListProvider.notifier).loadDemoData();
                      ref.read(savingsListProvider.notifier).loadDemoData();
                      ref.read(budgetListProvider.notifier).loadDemoData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos de demostración cargados con éxito.'),
                          backgroundColor: TivoColors.statusIncomeGreen,
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                    title: const Text(
                      'Borrar todos los datos (\$0)',
                      style: TextStyle(
                        color: TivoColors.statusExpenseRoseLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Reiniciar la app limpia en \$0 para ingresar tus propios datos', style: TextStyle(color: TivoColors.textTertiary, fontSize: 11)),
                    onTap: () => _showDeleteDataConfirmation(context, ref),
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
