import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';

class ExpenseChart extends StatefulWidget {
  final Map<String, double> categoryData;
  final double totalAmount;

  const ExpenseChart({
    super.key,
    required this.categoryData,
    required this.totalAmount,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int _selectedChartType = 0; // 0 = Círculo / Donut, 1 = Barras

  final List<Color> _chartColors = [
    TivoColors.primaryIceBlue,
    TivoColors.statusExpenseRose,
    TivoColors.accentElectricCyan,
    TivoColors.accentPurple,
    TivoColors.statusWarningAmber,
    TivoColors.statusIncomeGreen,
    const Color(0xFFE879F9),
    const Color(0xFF38BDF8),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.categoryData.isEmpty || widget.totalAmount == 0) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        borderRadius: TivoSpacing.radiusLg,
        child: Column(
          children: const [
            Icon(LucideIcons.pieChart, size: 40, color: TivoColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No hay gastos registrados en este período',
              style: TextStyle(color: TivoColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Registra un movimiento para ver el desglose en gráficos.',
              style: TextStyle(color: TivoColors.textTertiary, fontSize: 11),
            ),
          ],
        ),
      );
    }

    final entries = widget.categoryData.entries.toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: TivoSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Toggle (Círculo vs Barras)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Gastos',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Total: ${CurrencyFormatter.formatCOP(widget.totalAmount)}',
                    style: const TextStyle(
                      color: TivoColors.statusExpenseRoseLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Segmented Toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    _buildToggleItem(0, LucideIcons.pieChart, 'Círculo'),
                    _buildToggleItem(1, LucideIcons.barChart3, 'Barras'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Display (Pie or Bar)
          SizedBox(
            height: 190,
            child: _selectedChartType == 0
                ? _buildPieChart(entries)
                : _buildBarChart(entries),
          ),
          const SizedBox(height: 24),

          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),

          // Detailed Category Breakdown with Exact Amounts and Percentages
          const Text(
            'Desglose Detallado por Categoría',
            style: TextStyle(
              color: TivoColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = _chartColors[index % _chartColors.length];
            final percentage = (item.value / widget.totalAmount) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatCategoryLabel(item.key),
                          style: const TextStyle(
                            color: TivoColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: TivoColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.formatCOP(item.value),
                        style: const TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, IconData icon, String label) {
    final isSelected = _selectedChartType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? const Color(0xFF070E22) : TivoColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF070E22) : TivoColors.textTertiary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, double>> entries) {
    final List<PieChartSectionData> sections = [];

    for (int i = 0; i < entries.length; i++) {
      final amount = entries[i].value;
      final percentage = (amount / widget.totalAmount) * 100;
      final isLarge = percentage > 12;
      final color = _chartColors[i % _chartColors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: isLarge ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: 46,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF070E22),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 46,
            sections: sections,
            pieTouchData: PieTouchData(enabled: true),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.flame, size: 18, color: TivoColors.statusExpenseRose),
            const SizedBox(height: 2),
            Text(
              CurrencyFormatter.formatCompact(widget.totalAmount),
              style: const TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart(List<MapEntry<String, double>> entries) {
    final maxAmount = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxAmount * 1.15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cat = entries[group.x.toInt()].key;
              final val = rod.toY;
              return BarTooltipItem(
                '${_formatCategoryLabel(cat)}\n${CurrencyFormatter.formatCompact(val)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox();
                final index = value.toInt();
                if (index < 0 || index >= entries.length) return const SizedBox();
                final name = _formatCategoryLabel(entries[index].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    name.length > 5 ? '${name.substring(0, 4)}..' : name,
                    style: const TextStyle(
                      color: TivoColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = _chartColors[index % _chartColors.length];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value,
                color: color,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxAmount * 1.15,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatCategoryLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'food':
        return 'Alimentación & Mercado';
      case 'housing':
        return 'Vivienda & Arriendo';
      case 'utilities':
        return 'Servicios Públicos';
      case 'transport':
        return 'Transporte & Movilidad';
      case 'entertainment':
        return 'Ocio & Entretenimiento';
      case 'health':
        return 'Salud & Bienestar';
      case 'education':
        return 'Educación & Cursos';
      case 'shopping':
        return 'Compras & Ropa';
      case 'salary':
        return 'Nómina / Sueldo';
      case 'returns':
        return 'Rendimientos / Inversión';
      default:
        return raw.toUpperCase();
    }
  }
}
