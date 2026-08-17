import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/transaction_provider.dart';
import '../domain/models/transaction_model.dart';
import 'add_transaction_modal.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todos', 'Gastos', 'Ingresos', 'Deseos'];

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionListProvider);

    final filteredTransactions = allTransactions.where((t) {
      if (_selectedFilterIndex == 1) return t.type == TransactionType.expense;
      if (_selectedFilterIndex == 2) return t.type == TransactionType.income;
      if (_selectedFilterIndex == 3) return t.necessity == NecessityType.want;
      return true;
    }).toList();

    double totalIn = 0;
    double totalOut = 0;
    for (final t in allTransactions) {
      if (t.type == TransactionType.income) totalIn += t.amount;
      if (t.type == TransactionType.expense) totalOut += t.amount;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Transacciones',
                        style: TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Historial y control de flujo',
                        style: TextStyle(
                          color: TivoColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => AddTransactionModal.show(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: TivoColors.primaryIceBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        color: Color(0xFF070E22),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Resumen de Flujo Mensual
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingresos Totales',
                            style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCOP(totalIn),
                            style: const TextStyle(
                              color: TivoColors.statusIncomeGreenLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 30, width: 1, color: Colors.white12),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gastos Totales',
                            style: TextStyle(color: TivoColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatCOP(totalOut),
                            style: const TextStyle(
                              color: TivoColors.statusExpenseRoseLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Filtros horizontales
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.asMap().entries.map((entry) {
                    final isSelected = _selectedFilterIndex == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = entry.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TivoColors.primaryIceBlue.withOpacity(0.2)
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                          border: Border.all(
                            color: isSelected ? TivoColors.primaryIceBlue : Colors.white10,
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Transacciones Filtradas
              if (filteredTransactions.isEmpty)
                const GlassCard(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No hay transacciones en este filtro.',
                      style: TextStyle(color: TivoColors.textSecondary),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredTransactions[index];
                    final isIncome = item.type == TransactionType.income;

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: TivoColors.statusExpenseRose.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                        ),
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        ref.read(transactionListProvider.notifier).deleteTransaction(item.id);
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: TivoSpacing.radiusMd,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item.category.color.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                              ),
                              child: Icon(
                                item.category.icon,
                                size: 22,
                                color: item.category.color,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: TivoColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        item.accountName,
                                        style: const TextStyle(
                                          color: TivoColors.textTertiary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${DateFormatter.relativeDay(item.date)}',
                                        style: const TextStyle(
                                          color: TivoColors.textTertiary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCOP(item.amount)}',
                                  style: TextStyle(
                                    color: isIncome
                                        ? TivoColors.statusIncomeGreen
                                        : TivoColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.necessity == NecessityType.want
                                        ? TivoColors.statusExpenseRose.withOpacity(0.12)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.necessity.label,
                                    style: TextStyle(
                                      color: item.necessity == NecessityType.want
                                          ? TivoColors.statusExpenseRoseLight
                                          : TivoColors.textTertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
