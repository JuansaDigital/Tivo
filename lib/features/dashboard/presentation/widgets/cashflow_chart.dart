import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../transactions/data/transaction_provider.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class CashflowChart extends ConsumerStatefulWidget {
  const CashflowChart({super.key});

  @override
  ConsumerState<CashflowChart> createState() => _CashflowChartState();
}

class _CashflowChartState extends ConsumerState<CashflowChart> {
  int _selectedDayIndex = 6; // Por defecto el último día (Hoy)

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final currentLang = ref.watch(languageProvider);
    final transactions = ref.watch(transactionListProvider);

    // Generar los últimos 7 días
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DateTime> last7Days = List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });

    // Calcular ingresos y gastos reales para cada uno de los 7 días
    final List<double> dailyIncome = List.filled(7, 0.0);
    final List<double> dailyExpense = List.filled(7, 0.0);

    for (final t in transactions) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      for (int i = 0; i < 7; i++) {
        if (tDate.isAtSameMomentAs(last7Days[i])) {
          if (t.type == TransactionType.income) {
            dailyIncome[i] += t.amount;
          } else if (t.type == TransactionType.expense || t.type == TransactionType.fixedCost) {
            dailyExpense[i] += t.amount;
          }
        }
      }
    }

    final hasAnyData = dailyIncome.any((v) => v > 0) || dailyExpense.any((v) => v > 0);
    final selectedDate = last7Days[_selectedDayIndex];
    final selectedIncome = dailyIncome[_selectedDayIndex];
    final selectedExpense = dailyExpense[_selectedDayIndex];

    double maxVal = 100000;
    for (int i = 0; i < 7; i++) {
      if (dailyIncome[i] > maxVal) maxVal = dailyIncome[i];
      if (dailyExpense[i] > maxVal) maxVal = dailyExpense[i];
    }

    final incomeSpots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), dailyIncome[i]);
    });

    final expenseSpots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), dailyExpense[i]);
    });

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: TivoSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings['cashflow_title'] ?? 'Flujo de Caja Real',
                    style: const TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings['cashflow_subtitle'] ?? 'Últimos 7 días sincronizados',
                    style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  _LegendItem(label: strings['income'] ?? 'Ingresos', color: TivoColors.statusIncomeGreen),
                  const SizedBox(width: 10),
                  _LegendItem(label: strings['expense'] ?? 'Gastos', color: TivoColors.statusExpenseRose),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini Calendario Selector Horizontal (7 Días)
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final d = last7Days[index];
                final isSelected = _selectedDayIndex == index;
                final isToday = d.isAtSameMomentAs(today);
                final hasActivity = dailyIncome[index] > 0 || dailyExpense[index] > 0;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TivoColors.primaryIceBlue
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? TivoColors.primaryIceBlue
                            : (hasActivity ? TivoColors.accentElectricCyan.withOpacity(0.3) : Colors.transparent),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? (strings['today'] ?? 'Hoy') : _shortDayName(d.weekday, currentLang),
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF070E22) : TivoColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Resumen del día seleccionado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentLang == AppLanguage.en
                      ? '${_fullDayName(selectedDate.weekday, currentLang)}, ${_monthName(selectedDate.month, currentLang)} ${selectedDate.day}'
                      : '${_fullDayName(selectedDate.weekday, currentLang)}, ${selectedDate.day} de ${_monthName(selectedDate.month, currentLang)}',
                  style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      '+${CurrencyFormatter.formatCompact(selectedIncome)}',
                      style: const TextStyle(color: TivoColors.statusIncomeGreenLight, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-${CurrencyFormatter.formatCompact(selectedExpense)}',
                      style: const TextStyle(color: TivoColors.statusExpenseRoseLight, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Gráfica LineChart sincronizada
          if (!hasAnyData)
            Container(
              height: 110,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.barChart2, size: 28, color: TivoColors.textTertiary),
                  const SizedBox(height: 6),
                  Text(
                    strings['no_movements_7d'] ?? 'Sin movimientos en los últimos 7 días (\$0)',
                    style: const TextStyle(color: TivoColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 130,
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
                        reservedSize: 20,
                        interval: 1.0,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox();
                          final idx = value.toInt();
                          if (idx < 0 || idx >= 7) return const SizedBox();
                          final d = last7Days[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${d.day}',
                              style: TextStyle(
                                color: idx == _selectedDayIndex ? TivoColors.primaryIceBlue : TivoColors.textTertiary,
                                fontSize: 10,
                                fontWeight: idx == _selectedDayIndex ? FontWeight.w800 : FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxVal * 1.15,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isInc = spot.barIndex == 0;
                          final label = isInc ? (strings['income'] ?? 'Ingreso') : (strings['expense'] ?? 'Gasto');
                          return LineTooltipItem(
                            '$label: ${CurrencyFormatter.formatCompact(spot.y)}',
                            TextStyle(
                              color: isInc ? TivoColors.statusIncomeGreenLight : TivoColors.statusExpenseRoseLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    // Línea de Ingresos (Verde)
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: TivoColors.statusIncomeGreen,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: index == _selectedDayIndex ? 4 : 2,
                            color: TivoColors.statusIncomeGreen,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            TivoColors.statusIncomeGreen.withOpacity(0.18),
                            TivoColors.statusIncomeGreen.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),

                    // Línea de Gastos (Rose)
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: TivoColors.statusExpenseRose,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: index == _selectedDayIndex ? 4 : 2,
                            color: TivoColors.statusExpenseRose,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            TivoColors.statusExpenseRose.withOpacity(0.15),
                            TivoColors.statusExpenseRose.withOpacity(0.0),
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

  String _shortDayName(int weekday, AppLanguage lang) {
    if (lang == AppLanguage.en) {
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[weekday - 1];
    }
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return names[weekday - 1];
  }

  String _fullDayName(int weekday, AppLanguage lang) {
    if (lang == AppLanguage.en) {
      const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return names[weekday - 1];
    }
    const names = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return names[weekday - 1];
  }

  String _monthName(int month, AppLanguage lang) {
    if (lang == AppLanguage.en) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1];
    }
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: TivoColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

