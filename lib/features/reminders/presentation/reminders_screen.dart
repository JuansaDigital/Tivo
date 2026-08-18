import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../savings/data/savings_provider.dart';
import '../../savings/presentation/savings_form_modal.dart';
import '../../savings/presentation/add_contribution_modal.dart';
import '../data/reminders_provider.dart';
import '../domain/models/reminder_model.dart';
import 'reminder_form_modal.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider);

    final fixedUtilities = reminders
        .where((r) => r.pillar == ReminderPillar.fixedUtility || r.pillar == ReminderPillar.subscription)
        .toList();
    final creditDebts = reminders
        .where((r) => r.pillar == ReminderPillar.creditDebt)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_reminders',
        backgroundColor: TivoColors.primaryIceBlue,
        foregroundColor: const Color(0xFF070E22),
        onPressed: () {
          ReminderFormModal.show(context);
        },
        child: const Icon(LucideIcons.plus),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Recordatorios & Alertas',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Panel Inteligente de 3 Puntos Clave',
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 📌 Servicios Públicos, Suscripciones y Pagos Fijos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildSectionHeader(
                      icon: LucideIcons.receiptText,
                      title: 'Servicios & Pagos Fijos',
                      subtitle: 'Facturas recurrentes con pago 1-Tap',
                      badgeColor: TivoColors.primaryIceBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plusCircle, color: TivoColors.primaryIceBlue),
                    onPressed: () {
                      ReminderFormModal.show(context, initialPillar: ReminderPillar.fixedUtility);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (fixedUtilities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text('No hay servicios registrados', style: TextStyle(color: TivoColors.textTertiary, fontSize: 12)),
                  ),
                )
              else
                ...fixedUtilities.map((r) => _ReminderCard(reminder: r)),

              const SizedBox(height: 22),

              // 📌 Tarjetas de Crédito y Deudas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildSectionHeader(
                      icon: LucideIcons.creditCard,
                      title: 'Tarjetas & Deudas',
                      subtitle: 'Fechas de corte, pago total vs mínimo',
                      badgeColor: TivoColors.statusExpenseRose,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plusCircle, color: TivoColors.statusExpenseRose),
                    onPressed: () {
                      ReminderFormModal.show(context, initialPillar: ReminderPillar.creditDebt);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Tip de optimización de corte
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TivoColors.accentElectricCyan.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                  border: Border.all(color: TivoColors.accentElectricCyan.withOpacity(0.25)),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.sparkles, size: 18, color: TivoColors.accentNeonCyan),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '💡 Tip: Usa tu tarjeta Nu a partir de mañana (Día 16) para financiar tus compras a 45 días sin pagar intereses.',
                        style: TextStyle(color: TivoColors.textPrimary, fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...creditDebts.map((r) => _ReminderCard(reminder: r, isCreditDebt: true)),

              const SizedBox(height: 22),

              // 📌 Metas de Ahorro Programado y Presupuestos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildSectionHeader(
                      icon: LucideIcons.target,
                      title: 'Metas & Ahorro Programado',
                      subtitle: 'Transferencias periódicas y fondos de reserva',
                      badgeColor: TivoColors.statusIncomeGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plusCircle, color: TivoColors.statusIncomeGreen),
                    onPressed: () {
                      SavingsFormModal.show(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, child) {
                  final savingsGoals = ref.watch(savingsListProvider);
                  if (savingsGoals.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No hay metas de ahorro registradas', style: TextStyle(color: TivoColors.textTertiary)),
                      ),
                    );
                  }
                  return Column(
                    children: savingsGoals.map((g) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(g.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: TivoColors.statusExpenseRose, borderRadius: BorderRadius.circular(TivoSpacing.radiusMd)),
                            child: const Icon(LucideIcons.trash2, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(savingsListProvider.notifier).deleteGoal(g.id);
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: TivoSpacing.radiusLg,
                            onTap: () {
                              SavingsFormModal.show(context, goalToEdit: g);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      g.title,
                                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${((g.currentAmount / g.targetAmount).clamp(0.0, 1.0) * 100).round()}%',
                                      style: TextStyle(color: g.color, fontSize: 13, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (g.currentAmount / g.targetAmount).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withOpacity(0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(g.color),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Aporte sugerido: ${CurrencyFormatter.formatCOP(g.monthlyContribution)}/mes',
                                      style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                                    ),
                                    Text(
                                      '${CurrencyFormatter.formatCompact(g.currentAmount)} / ${CurrencyFormatter.formatCompact(g.targetAmount)}',
                                      style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () => AddContributionModal.show(context, goal: g),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: TivoColors.statusIncomeGreen.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                                          border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(LucideIcons.plus, size: 12, color: TivoColors.statusIncomeGreenLight),
                                            SizedBox(width: 4),
                                            Text(
                                              'Aportar Dinero Extra',
                                              style: TextStyle(
                                                color: TivoColors.statusIncomeGreenLight,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: badgeColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  final ReminderModel reminder;
  final bool isCreditDebt;

  const _ReminderCard({
    required this.reminder,
    this.isCreditDebt = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Dismissible(
        key: Key(reminder.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: TivoColors.statusExpenseRose,
            borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
          ),
          child: const Icon(LucideIcons.trash2, color: Colors.white),
        ),
        onDismissed: (_) {
          ref.read(reminderListProvider.notifier).deleteReminder(reminder.id);
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: TivoSpacing.radiusLg,
          onTap: () {
            ReminderFormModal.show(context, reminderToEdit: reminder);
          },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: const TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (reminder.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TivoColors.statusIncomeGreen.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '✓ Pagado',
                      style: TextStyle(color: TivoColors.statusIncomeGreenLight, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  Text(
                    'Vence en ${reminder.daysUntilDue} días',
                    style: TextStyle(
                      color: reminder.isUrgent ? TivoColors.statusExpenseRoseLight : TivoColors.statusWarningAmberLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.formatCOP(reminder.estimatedAmount),
                        style: const TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (reminder.notes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            reminder.notes!,
                            style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!reminder.isPaid)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(reminderListProvider.notifier).markAsPaid(reminder.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pago de "${reminder.title}" registrado.'),
                          backgroundColor: TivoColors.statusIncomeGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TivoColors.primaryIceBlue,
                      foregroundColor: const Color(0xFF070E22),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TivoSpacing.radiusPill)),
                    ),
                    child: const Text('Pagar 1-Tap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            if (isCreditDebt && reminder.minimumPayment != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pago Mínimo: ${CurrencyFormatter.formatCOP(reminder.minimumPayment!)}',
                      style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                    ),
                    const Text(
                      '⚠️ Evita intereses pagando el total',
                      style: TextStyle(color: TivoColors.statusWarningAmberLight, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
