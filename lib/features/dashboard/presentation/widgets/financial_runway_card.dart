import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tivo_score_gauge.dart';
import '../../data/metrics_provider.dart';

class FinancialRunwayCard extends StatelessWidget {
  final FinancialMetrics metrics;

  const FinancialRunwayCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PATRIMONIO NETO',
                    style: TextStyle(
                      color: TivoColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatCOP(metrics.netWorth),
                    style: const TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              TivoScoreGauge(
                score: metrics.tivoScore,
                size: 85,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Pista Financiera & Distribución
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: TivoColors.accentElectricCyan.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                    border: Border.all(
                      color: TivoColors.accentElectricCyan.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.hourglass,
                        size: 18,
                        color: TivoColors.accentElectricCyan,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Pista Financiera',
                              style: TextStyle(
                                color: TivoColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${metrics.financialRunwayMonths} meses',
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: TivoColors.statusIncomeGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                    border: Border.all(
                      color: TivoColors.statusIncomeGreen.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.flame,
                        size: 18,
                        color: TivoColors.statusIncomeGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Racha de Control',
                              style: TextStyle(
                                color: TivoColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${metrics.streakDays} días',
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
    );
  }
}
