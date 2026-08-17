import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glowing_badge.dart';

class SubscriptionRadarCard extends StatelessWidget {
  final double monthlyTotal;
  final double annualTotal;

  const SubscriptionRadarCard({
    super.key,
    required this.monthlyTotal,
    required this.annualTotal,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: TivoColors.accentPurple.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.repeat,
                      size: 16,
                      color: TivoColors.accentPurple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Radar de Suscripciones',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const GlowingBadge(
                text: 'Subscription Creep',
                color: TivoColors.accentPurple,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comprometido al Mes',
                      style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCOP(monthlyTotal),
                      style: const TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 28, width: 1, color: Colors.white12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Costo Proyectado (1 Año)',
                      style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCOP(annualTotal),
                      style: const TextStyle(
                        color: TivoColors.statusWarningAmberLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.20),
              borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: const [
                Icon(LucideIcons.sparkles, size: 14, color: TivoColors.primaryIceBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detectamos 2 suscripciones activas (Spotify + Netflix).',
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
