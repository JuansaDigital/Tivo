import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/data/transaction_provider.dart';
import '../../../transactions/presentation/add_transaction_modal.dart';

class RecentTransactionsList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final VoidCallback onViewAll;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: const Row(
                children: [
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      color: TivoColors.primaryIceBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: TivoColors.primaryIceBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No hay transacciones registradas aún.',
                style: TextStyle(color: TivoColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = transactions[index];
              final isIncome = item.type == TransactionType.income;

              return Dismissible(
                key: Key(item.id),
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
                onDismissed: (direction) {
                  ref.read(transactionListProvider.notifier).deleteTransaction(item.id);
                },
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: TivoSpacing.radiusMd,
                  onTap: () {
                    AddTransactionModal.show(context, transactionToEdit: item);
                  },
                  child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.category.color.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                      ),
                      child: Icon(
                        item.category.icon,
                        size: 20,
                        color: item.category.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.accountName} • ${DateFormatter.relativeDay(item.date)}',
                            style: const TextStyle(
                              color: TivoColors.textTertiary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                              fontSize: 9,
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
    );
  }
}
