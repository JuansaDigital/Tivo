import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class DailyTipCard extends StatelessWidget {
  final VoidCallback onOpenTips;

  const DailyTipCard({
    super.key,
    required this.onOpenTips,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: TivoSpacing.radiusLg,
      backgroundColor: TivoColors.accentElectricCyan.withOpacity(0.08),
      onTap: onOpenTips,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TivoColors.accentElectricCyan.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.lightbulb,
              size: 18,
              color: TivoColors.accentNeonCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PÍLDORA FINANCIERA DEL DÍA',
                  style: TextStyle(
                    color: TivoColors.accentNeonCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pagar tu tarjeta a 1 cuota evita el 100% de intereses y acumula cashback o millas gratis.',
                  style: TextStyle(
                    color: TivoColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.arrowRight,
            size: 16,
            color: TivoColors.accentElectricCyan,
          ),
        ],
      ),
    );
  }
}
