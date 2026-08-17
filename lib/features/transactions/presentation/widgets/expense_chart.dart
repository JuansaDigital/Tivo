import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/tivo_colors.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final double totalAmount;

  const ExpenseChart({
    super.key,
    required this.categoryData,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty || totalAmount == 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Sin datos suficientes',
            style: TextStyle(color: TivoColors.textTertiary),
          ),
        ),
      );
    }

    final List<Color> chartColors = [
      TivoColors.primaryIceBlue,
      TivoColors.statusExpenseRose,
      TivoColors.accentElectricCyan,
      TivoColors.accentPurple,
      TivoColors.statusWarningAmber,
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = [];

    categoryData.forEach((category, amount) {
      final isLarge = (amount / totalAmount) > 0.1;
      sections.add(
        PieChartSectionData(
          color: chartColors[colorIndex % chartColors.length],
          value: amount,
          title: isLarge ? '${((amount / totalAmount) * 100).toStringAsFixed(0)}%' : '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF070E22),
          ),
        ),
      );
      colorIndex++;
    });

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: sections,
          pieTouchData: PieTouchData(enabled: true),
        ),
      ),
    );
  }
}
