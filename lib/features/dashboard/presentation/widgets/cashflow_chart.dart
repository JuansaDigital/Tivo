import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class CashflowChart extends StatelessWidget {
  const CashflowChart({super.key});

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
              const Text(
                'Flujo de Caja Semanal',
                style: TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  _LegendItem(label: 'Ingresos', color: TivoColors.statusIncomeGreen),
                  const SizedBox(width: 12),
                  _LegendItem(label: 'Gastos', color: TivoColors.primaryIceBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: TivoColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Sem 1', style: style);
                          case 1:
                            return const Text('Sem 2', style: style);
                          case 2:
                            return const Text('Sem 3', style: style);
                          case 3:
                            return const Text('Sem 4', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  // Línea de Ingresos (Verde/Cyan)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4.5),
                      FlSpot(1, 2.0),
                      FlSpot(2, 4.8),
                      FlSpot(3, 3.2),
                    ],
                    isCurved: true,
                    color: TivoColors.statusIncomeGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TivoColors.statusIncomeGreen.withOpacity(0.20),
                          TivoColors.statusIncomeGreen.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // Línea de Gastos (Ice Blue)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.8),
                      FlSpot(1, 2.6),
                      FlSpot(2, 1.4),
                      FlSpot(3, 2.1),
                    ],
                    isCurved: true,
                    color: TivoColors.primaryIceBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TivoColors.primaryIceBlue.withOpacity(0.18),
                          TivoColors.primaryIceBlue.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
