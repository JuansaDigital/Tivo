import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../reminders/data/reminders_provider.dart';

class ImmediateAlertBanner extends ConsumerWidget {
  final VoidCallback onTap;

  const ImmediateAlertBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider);
    final pending = reminders.where((r) => !r.isPaid).toList();

    if (pending.isEmpty) return const SizedBox.shrink();

    final next = pending.first;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: TivoSpacing.radiusMd,
      backgroundColor: TivoColors.statusWarningAmber.withOpacity(0.12),
      borderGradient: LinearGradient(
        colors: [
          TivoColors.statusWarningAmber.withOpacity(0.4),
          TivoColors.statusWarningAmber.withOpacity(0.1),
        ],
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: TivoColors.statusWarningAmber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bellRing,
              size: 15,
              color: TivoColors.statusWarningAmberLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Alerta: ${next.title} vence en ${next.daysUntilDue} días.',
              style: const TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 14,
            color: TivoColors.statusWarningAmberLight,
          ),
        ],
      ),
    );
  }
}
