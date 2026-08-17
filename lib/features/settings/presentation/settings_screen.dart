import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../accounts/data/account_provider.dart';
import '../../transactions/data/transaction_provider.dart';
import '../../reminders/data/reminders_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/currency_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showDeleteDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TivoColors.bgDeepNavy,
          title: const Text(
            'Borrar todos los datos',
            style: TextStyle(color: TivoColors.statusExpenseRoseLight, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar permanentemente todas tus cuentas, transacciones y recordatorios? Esta acción no se puede deshacer.',
            style: TextStyle(color: TivoColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: TivoColors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                // Wipe data
                ref.read(accountListProvider.notifier).reset();
                ref.read(transactionListProvider.notifier).reset();
                ref.read(reminderListProvider.notifier).reset();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los datos han sido borrados'),
                    backgroundColor: TivoColors.statusExpenseRose,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.statusExpenseRose,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // User Profile Section
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
            
            // Preferences Section
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reinicia la app para aplicar el idioma.'), backgroundColor: TivoColors.statusIncomeGreen),
                          );
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
                            curr.name,
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
            
            // Danger Zone Section
            const Text(
              'Zona de Peligro',
              style: TextStyle(
                color: TivoColors.statusExpenseRose,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: TivoSpacing.radiusLg,
              backgroundColor: TivoColors.statusExpenseRose.withOpacity(0.05),
              borderGradient: LinearGradient(
                colors: [
                  TivoColors.statusExpenseRose.withOpacity(0.3),
                  TivoColors.statusExpenseRose.withOpacity(0.0),
                ],
              ),
              child: ListTile(
                leading: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                title: const Text(
                  'Borrar todos los datos',
                  style: TextStyle(
                    color: TivoColors.statusExpenseRoseLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showDeleteDataConfirmation(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
