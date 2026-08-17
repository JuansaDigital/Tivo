import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glowing_badge.dart';
import '../../data/metrics_provider.dart';

class SafeToSpendCard extends StatelessWidget {
  final FinancialMetrics metrics;

  const SafeToSpendCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hasGlow: true,
      glowColor: TivoColors.primaryIceBlue,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x3338BDF8),
          Color(0x1F06B6D4),
          Color(0x241C2541),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
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
                      color: TivoColors.primaryIceBlue.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      size: 18,
                      color: TivoColors.primaryIceBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAFE-TO-SPEND',
                        style: TextStyle(
                          color: TivoColors.primaryIceBlue.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Dinero libre de compromisos',
                        style: TextStyle(
                          color: TivoColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const GlowingBadge(
                text: 'Hoy',
                color: TivoColors.accentNeonCyan,
                icon: LucideIcons.sparkles,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Monto diario destacado
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.formatCOP(metrics.safeToSpendToday),
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '/ día',
                style: TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 16),

          // Barra de progreso y desglose mensual
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.20),
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restante este mes',
                      style: TextStyle(
                        color: TivoColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatCOP(metrics.safeToSpendMonth),
                      style: const TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Fijos & Ahorro',
                      style: TextStyle(
                        color: TivoColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(LucideIcons.lock, size: 12, color: TivoColors.statusIncomeGreen),
                        SizedBox(width: 4),
                        Text(
                          '100% Asegurados',
                          style: TextStyle(
                            color: TivoColors.statusIncomeGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
