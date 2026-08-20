import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../accounts/presentation/account_form_modal.dart';
import '../../accounts/data/account_provider.dart';
import '../../accounts/domain/models/account_model.dart';
import '../../budgets/data/budget_provider.dart';
import '../../budgets/presentation/budget_form_modal.dart';
import '../data/transaction_provider.dart';
import '../domain/models/transaction_model.dart';
import 'add_transaction_modal.dart';
import 'widgets/expense_chart.dart';
import '../../savings/data/savings_provider.dart';
import '../../savings/presentation/savings_form_modal.dart';
import '../../savings/presentation/add_contribution_modal.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  final int initialSubTab;
  const FinancesScreen({super.key, this.initialSubTab = 0});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen> {
  late int _selectedSubTab;
  TransactionType? _typeFilter;
  DateTime? _selectedDateFilter;

  DateTime _focusedCalendarDate = DateTime.now();
  DateTime? _selectedCalendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedSubTab = widget.initialSubTab;
    _selectedDateFilter = null; // Mostrar todos los movimientos por defecto
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider);
    final accounts = ref.watch(accountListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Finanzas Personales',
                        style: TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Motor Operativo, Cuentas & Ahorro',
                        style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => AddTransactionModal.show(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TivoColors.primaryIceBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: TivoColors.primaryIceBlue),
                      ),
                      child: const Icon(LucideIcons.plus, size: 18, color: TivoColors.primaryIceBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barra de Subpestañas (Glassmorphic Segmented Control con 5 pestañas)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _subTabItem('Movimientos', 0),
                      _subTabItem('Cuentas', 1),
                      _subTabItem('Presupuestos', 2),
                      _subTabItem('Ahorro', 3),
                      _subTabItem('Calendario', 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Contenido según Subpestaña
              if (_selectedSubTab == 0) ...[
                // Subtab 0: Movimientos
                _buildExpenseChartView(transactions),
                const SizedBox(height: 20),
                _buildFilterChips(),
                const SizedBox(height: 20),
                _buildDateSelector(),
                const SizedBox(height: 20),
                _buildTransactionsList(transactions),
              ] else if (_selectedSubTab == 1) ...[
                // Subtab 1: Cuentas e Instrumentos
                _buildAccountsView(accounts),
              ] else if (_selectedSubTab == 2) ...[
                // Subtab 2: Presupuestos por Categoría
                _buildBudgetsView(),
              ] else if (_selectedSubTab == 3) ...[
                // Subtab 3: Metas de Ahorro
                _buildSavingsView(),
              ] else ...[
                // Subtab 4: Calendario Financiero Interactivo
                _buildCalendarTab(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTabItem(String title, int index) {
    final isSelected = _selectedSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsView() {
    final savingsGoals = ref.watch(savingsListProvider);

    double totalCurrent = 0;
    double totalTarget = 0;
    for (var g in savingsGoals) {
      totalCurrent += g.currentAmount;
      totalTarget += g.targetAmount;
    }
    final totalProgress = totalTarget > 0 ? (totalCurrent / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta Resumen Global de Ahorro
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: TivoSpacing.radiusXl,
          hasGlow: true,
          glowColor: TivoColors.statusIncomeGreen,
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
                        'TOTAL EN METAS DE AHORRO',
                        style: TextStyle(
                          color: TivoColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.formatCOP(totalCurrent),
                        style: const TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TivoColors.statusIncomeGreen.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.piggyBank, color: TivoColors.statusIncomeGreen, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalProgress,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(TivoColors.statusIncomeGreen),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(totalProgress * 100).toStringAsFixed(0)}% del objetivo acumulado',
                    style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Meta: ${CurrencyFormatter.formatCompact(totalTarget)}',
                    style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Cabecera con botón de agregar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Metas y Bolsillos de Reserva',
              style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            IconButton(
              icon: const Icon(LucideIcons.plusCircle, color: TivoColors.statusIncomeGreen),
              onPressed: () => SavingsFormModal.show(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (savingsGoals.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: TivoSpacing.radiusLg,
            child: Center(
              child: Column(
                children: [
                  const Icon(LucideIcons.target, size: 40, color: TivoColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay metas de ahorro activas',
                    style: TextStyle(color: TivoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Crea una meta (Ej: Vacaciones, Fondo de Emergencia, Comprar Moto) para empezar a ahorrar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => SavingsFormModal.show(context),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Nueva Meta de Ahorro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TivoColors.statusIncomeGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savingsGoals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = savingsGoals[index];
              final progress = (g.currentAmount / g.targetAmount).clamp(0.0, 1.0);

              return Dismissible(
                key: Key(g.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: TivoColors.statusExpenseRose,
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(savingsListProvider.notifier).deleteGoal(g.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Meta "${g.title}" eliminada'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: TivoSpacing.radiusLg,
                  onTap: () => SavingsFormModal.show(context, goalToEdit: g),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g.title,
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: g.color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                              border: Border.all(color: g.color.withOpacity(0.4)),
                            ),
                            child: Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(color: g.color, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(g.color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aporte mensual: ${CurrencyFormatter.formatCompact(g.monthlyContribution)}',
                            style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                          ),
                          Text(
                            '${CurrencyFormatter.formatCompact(g.currentAmount)} / ${CurrencyFormatter.formatCompact(g.targetAmount)}',
                            style: const TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => AddContributionModal.show(context, goal: g),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: TivoColors.statusIncomeGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                                border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(LucideIcons.plus, size: 12, color: TivoColors.statusIncomeGreenLight),
                                  SizedBox(width: 4),
                                  Text(
                                    'Aportar Dinero Extra',
                                    style: TextStyle(
                                      color: TivoColors.statusIncomeGreenLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Todos', 'type': null},
      {'label': 'Gastos', 'type': TransactionType.expense},
      {'label': 'Ingresos', 'type': TransactionType.income},
      {'label': 'Costos Fijos', 'type': TransactionType.fixedCost},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _typeFilter == f['type'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(f['label'] as String),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: Colors.white.withOpacity(0.06),
              selectedColor: TivoColors.accentElectricCyan,
              checkmarkColor: const Color(0xFF070E22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                side: BorderSide(
                  color: isSelected ? TivoColors.accentElectricCyan : Colors.white12,
                ),
              ),
              onSelected: (_) {
                setState(() => _typeFilter = f['type'] as TransactionType?);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseChartView(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense || t.type == TransactionType.fixedCost).toList();
    
    Map<String, double> categoryData = {};
    double totalExpense = 0;

    for (var t in expenses) {
      final catName = t.category.toString().split('.').last;
      categoryData[catName] = (categoryData[catName] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    return ExpenseChart(categoryData: categoryData, totalAmount: totalExpense);
  }

  Widget _buildDateSelector() {
    // Generar los últimos 14 días y el día de hoy
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DateTime> dates = List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length + 1, // +1 para el botón "Todos"
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedDateFilter == null;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDateFilter = null);
              },
              child: Container(
                width: 58,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected ? TivoColors.primaryIceBlue : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.layers,
                      size: 16,
                      color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Todos',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF070E22) : TivoColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final date = dates[index - 1];
          final isSelected = _selectedDateFilter != null && _selectedDateFilter!.isAtSameMomentAs(date);
          final isToday = date.isAtSameMomentAs(today);

          final dayNum = date.day.toString();

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDateFilter = null; // Deseleccionar para ver todos
                } else {
                  _selectedDateFilter = date;
                }
              });
            },
            child: Container(
              width: 54,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? TivoColors.primaryIceBlue : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Hoy' : _getShortWeekDay(date.weekday),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF070E22) : TivoColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getShortWeekDay(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    var filtered = _typeFilter == null
        ? transactions
        : transactions.where((t) => t.type == _typeFilter).toList();

    if (_selectedDateFilter != null) {
      filtered = filtered.where((t) {
        final tDate = DateTime(t.date.year, t.date.month, t.date.day);
        return tDate.isAtSameMomentAs(_selectedDateFilter!);
      }).toList();
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No hay movimientos registrados.',
            style: TextStyle(color: TivoColors.textTertiary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = filtered[index];
        final isIncome = t.type == TransactionType.income;

        return Dismissible(
          key: Key(t.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: TivoColors.statusExpenseRose,
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
            ),
            child: const Icon(LucideIcons.trash2, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(transactionListProvider.notifier).deleteTransaction(t.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Movimiento "${t.title}" eliminado'),
                backgroundColor: TivoColors.statusExpenseRose,
              ),
            );
          },
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: TivoSpacing.radiusMd,
            onTap: () {
              AddTransactionModal.show(context, transactionToEdit: t);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: t.category.color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(t.category.icon, size: 18, color: t.category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: const TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${t.category.label} • ${t.accountName}',
                            style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                          ),
                          if (t.tag != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: TivoColors.primaryIceBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.tag!,
                                style: const TextStyle(
                                  color: TivoColors.primaryIceBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCOP(t.amount)}',
                  style: TextStyle(
                    color: isIncome ? TivoColors.statusIncomeGreenLight : TivoColors.statusExpenseRoseLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountsView(List<AccountModel> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuentas, Tarjetas & Bolsillos',
          style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final acc = accounts[index];
            final isCredit = acc.type == AccountType.creditCard;

            return GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: TivoSpacing.radiusLg,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AccountFormModal(accountToEdit: acc),
                );
              },
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
                              color: acc.type.color.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(acc.type.icon, size: 18, color: acc.type.color),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.name,
                                style: const TextStyle(
                                  color: TivoColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${acc.institutionName} • ${acc.accountNumberMasked}',
                                style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (acc.isGMFExempt)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: TivoColors.statusIncomeGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.4)),
                          ),
                          child: const Text(
                            'Exenta 4x1000',
                            style: TextStyle(
                              color: TivoColors.statusIncomeGreenLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCredit ? 'Consumo Facturado' : 'Saldo Disponible',
                            style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatCOP(acc.balance),
                            style: TextStyle(
                              color: isCredit ? TivoColors.statusExpenseRoseLight : TivoColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (isCredit)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cupo Disponible',
                              style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatCOP(acc.availableCredit),
                              style: const TextStyle(
                                color: TivoColors.accentNeonCyan,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (isCredit) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📅 Corte: Día ${acc.cutOffDay}',
                            style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                          ),
                          Text(
                            '⏰ Pago Límite: Día ${acc.paymentDueDay}',
                            style: const TextStyle(color: TivoColors.statusWarningAmberLight, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AccountFormModal(),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 20),
            label: const Text(
              'Añadir Nueva Cuenta',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: TivoColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                side: const BorderSide(color: Colors.white10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetsView() {
    final budgets = ref.watch(budgetListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Control de Presupuestos',
              style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            IconButton(
              icon: const Icon(LucideIcons.plusCircle, color: TivoColors.primaryIceBlue),
              onPressed: () {
                BudgetFormModal.show(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (budgets.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                'No hay presupuestos registrados.',
                style: TextStyle(color: TivoColors.textTertiary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = budgets[index];
              final progress = (b.spentAmount / b.limitAmount).clamp(0.0, 1.0);
              final isExceeded = b.spentAmount > b.limitAmount;

              return Dismissible(
                key: Key(b.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: TivoColors.statusExpenseRose,
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(budgetListProvider.notifier).deleteBudget(b.id);
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: TivoSpacing.radiusMd,
                  onTap: () {
                    BudgetFormModal.show(context, budgetToEdit: b);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            b.categoryName,
                            style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: isExceeded ? TivoColors.statusExpenseRoseLight : b.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(isExceeded ? TivoColors.statusExpenseRose : b.color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gastado: ${CurrencyFormatter.formatCOP(b.spentAmount)}',
                            style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                          ),
                          Text(
                            'Límite: ${CurrencyFormatter.formatCOP(b.limitAmount)}',
                            style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCalendarTab() {
    final transactions = ref.watch(transactionListProvider);

    // Filtrar movimientos del día seleccionado usando isSameDay
    final selectedDayTransactions = transactions.where((t) {
      if (_selectedCalendarDate == null) return false;
      return isSameDay(t.date, _selectedCalendarDate);
    }).toList();

    // Calcular estadísticas del mes enfocado
    final monthTransactions = transactions.where((t) {
      return t.date.year == _focusedCalendarDate.year && t.date.month == _focusedCalendarDate.month;
    }).toList();

    double monthIncome = 0;
    double monthExpense = 0;
    for (final t in monthTransactions) {
      if (t.type == TransactionType.income) {
        monthIncome += t.amount;
      } else {
        monthExpense += t.amount;
      }
    }
    final monthNet = monthIncome - monthExpense;

    // Calcular estadísticas del día seleccionado
    double dayIncome = 0;
    double dayExpense = 0;
    for (final t in selectedDayTransactions) {
      if (t.type == TransactionType.income) {
        dayIncome += t.amount;
      } else {
        dayExpense += t.amount;
      }
    }
    final dayNet = dayIncome - dayExpense;

    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final currentMonthName = months[_focusedCalendarDate.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta Resumen Mensual
        GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: TivoSpacing.radiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.calendarDays, size: 16, color: TivoColors.primaryIceBlue),
                      const SizedBox(width: 8),
                      Text(
                        'Resumen de $currentMonthName ${_focusedCalendarDate.year}',
                        style: const TextStyle(color: TivoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: monthNet >= 0
                          ? TivoColors.statusIncomeGreen.withOpacity(0.15)
                          : TivoColors.statusExpenseRose.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                    ),
                    child: Text(
                      'Neto: ${CurrencyFormatter.format(monthNet, showSign: true)}',
                      style: TextStyle(
                        color: monthNet >= 0 ? TivoColors.statusIncomeGreenLight : TivoColors.statusExpenseRoseLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                        border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ingresos del Mes', style: TextStyle(color: TivoColors.textTertiary, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(
                            '+${CurrencyFormatter.format(monthIncome)}',
                            style: const TextStyle(color: TivoColors.statusIncomeGreenLight, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                        border: Border.all(color: TivoColors.statusExpenseRose.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gastos del Mes', style: TextStyle(color: TivoColors.textTertiary, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(
                            '-${CurrencyFormatter.format(monthExpense)}',
                            style: const TextStyle(color: TivoColors.statusExpenseRoseLight, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Calendario Interactivo
        GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: TivoSpacing.radiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Calendario Financiero',
                    style: TextStyle(color: TivoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _CalendarLegend(color: TivoColors.statusIncomeGreen, label: 'Ingresos'),
                  _CalendarLegend(color: TivoColors.statusExpenseRose, label: 'Gastos'),
                ],
              ),
              const SizedBox(height: 14),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedCalendarDate,
                selectedDayPredicate: (day) => isSameDay(_selectedCalendarDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedCalendarDate = selectedDay;
                    _focusedCalendarDate = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedCalendarDate = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(color: TivoColors.textPrimary),
                  weekendTextStyle: const TextStyle(color: TivoColors.textSecondary),
                  selectedDecoration: const BoxDecoration(
                    color: TivoColors.primaryIceBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Color(0xFF070E22), fontWeight: FontWeight.bold),
                  todayDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.5)),
                  ),
                  todayTextStyle: const TextStyle(color: TivoColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: TivoColors.primaryIceBlue, fontSize: 16, fontWeight: FontWeight.w700),
                  leftChevronIcon: Icon(LucideIcons.chevronLeft, color: TivoColors.textSecondary),
                  rightChevronIcon: Icon(LucideIcons.chevronRight, color: TivoColors.textSecondary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: TivoColors.textSecondary, fontWeight: FontWeight.w600),
                  weekendStyle: TextStyle(color: TivoColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final dayTrans = transactions.where((t) => isSameDay(t.date, date)).toList();
                    if (dayTrans.isEmpty) return const SizedBox();

                    final hasIncome = dayTrans.any((t) => t.type == TransactionType.income);
                    final hasExpense = dayTrans.any((t) => t.type != TransactionType.income);

                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasIncome)
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: TivoColors.statusIncomeGreen, shape: BoxShape.circle)),
                          if (hasExpense)
                            Container(width: 5, height: 5, margin: const EdgeInsets.only(left: 3), decoration: const BoxDecoration(color: TivoColors.statusExpenseRose, shape: BoxShape.circle)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Detalle del Día Seleccionado
        if (_selectedCalendarDate != null) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: TivoSpacing.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatCalendarHeaderDate(_selectedCalendarDate!),
                          style: const TextStyle(color: TivoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedDayTransactions.length} movimiento${selectedDayTransactions.length == 1 ? '' : 's'}',
                          style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: TivoColors.primaryIceBlue.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: TivoColors.primaryIceBlue),
                        ),
                        child: const Icon(LucideIcons.plus, size: 16, color: TivoColors.primaryIceBlue),
                      ),
                      onPressed: () {
                        AddTransactionModal.show(context, initialDate: _selectedCalendarDate);
                      },
                    ),
                  ],
                ),
                if (selectedDayTransactions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (dayIncome > 0)
                        Expanded(
                          child: Text(
                            'Ingresos: +${CurrencyFormatter.format(dayIncome)}',
                            style: const TextStyle(color: TivoColors.statusIncomeGreenLight, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      if (dayExpense > 0)
                        Expanded(
                          child: Text(
                            'Gastos: -${CurrencyFormatter.format(dayExpense)}',
                            style: const TextStyle(color: TivoColors.statusExpenseRoseLight, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      if (dayIncome == 0 && dayExpense == 0)
                        Text(
                          'Balance neto: ${CurrencyFormatter.format(dayNet, showSign: true)}',
                          style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCalendarDayTransactionsList(selectedDayTransactions, _selectedCalendarDate!),
        ],
      ],
    );
  }

  String _formatCalendarHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final monthName = months[date.month - 1];

    if (target.isAtSameMomentAs(today)) {
      return 'Hoy (${date.day} de $monthName)';
    } else if (target.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Ayer (${date.day} de $monthName)';
    } else if (target.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Mañana (${date.day} de $monthName)';
    } else {
      return '${date.day} de $monthName, ${date.year}';
    }
  }

  Widget _buildCalendarDayTransactionsList(List<TransactionModel> dayTransactions, DateTime date) {
    if (dayTransactions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        borderRadius: TivoSpacing.radiusMd,
        child: Column(
          children: [
            Icon(LucideIcons.calendarX2, size: 36, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 10),
            const Text(
              'No hay movimientos para este día',
              style: TextStyle(color: TivoColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                AddTransactionModal.show(context, initialDate: date);
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Registrar Movimiento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.primaryIceBlue,
                foregroundColor: const Color(0xFF070E22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TivoSpacing.radiusPill)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayTransactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = dayTransactions[index];
        final isIncome = t.type == TransactionType.income;

        return Dismissible(
          key: Key('cal_${t.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: TivoColors.statusExpenseRose,
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
            ),
            child: const Icon(LucideIcons.trash2, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(transactionListProvider.notifier).deleteTransaction(t.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Movimiento "${t.title}" eliminado'),
                backgroundColor: TivoColors.statusExpenseRose,
              ),
            );
          },
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: TivoSpacing.radiusMd,
            onTap: () {
              AddTransactionModal.show(context, transactionToEdit: t, initialDate: date);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: t.category.color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(t.category.icon, size: 16, color: t.category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: const TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.category.label} • ${t.accountName}',
                        style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
                  style: TextStyle(
                    color: isIncome ? TivoColors.statusIncomeGreenLight : TivoColors.statusExpenseRoseLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _CalendarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

