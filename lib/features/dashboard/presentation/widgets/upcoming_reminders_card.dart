import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../reminders/data/reminders_provider.dart';

class UpcomingRemindersCard extends ConsumerWidget {
  final VoidCallback onViewAll;

  const UpcomingRemindersCard({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider);
    final pendingReminders = reminders.where((r) => !r.isPaid).toList();

    if (pendingReminders.isEmpty) return const SizedBox.shrink();

    final nextReminder = pendingReminders.first;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: TivoSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TivoColors.statusWarningAmber.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.alarmClock,
                      size: 16,
                      color: TivoColors.statusWarningAmber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Próximo Vencimiento',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: TivoColors.primaryIceBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextReminder.title,
                      style: const TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence en ${nextReminder.daysUntilDue} días • ${CurrencyFormatter.formatCOP(nextReminder.estimatedAmount)}',
                      style: const TextStyle(
                        color: TivoColors.statusWarningAmberLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(reminderListProvider.notifier).markAsPaid(nextReminder.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pago de "${nextReminder.title}" registrado con éxito.'),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Pagar 1-Tap',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
