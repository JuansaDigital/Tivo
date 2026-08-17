import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tivo_button.dart';
import '../../accounts/data/account_provider.dart';
import '../../accounts/domain/models/account_model.dart';
import '../../transactions/data/transaction_provider.dart';
import '../../transactions/domain/models/transaction_model.dart';
import '../data/savings_provider.dart';
import '../domain/models/savings_model.dart';

class AddContributionModal extends ConsumerStatefulWidget {
  final SavingsGoalModel goal;

  const AddContributionModal({super.key, required this.goal});

  static Future<void> show(BuildContext context, {required SavingsGoalModel goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContributionModal(goal: goal),
    );
  }

  @override
  ConsumerState<AddContributionModal> createState() => _AddContributionModalState();
}

class _AddContributionModalState extends ConsumerState<AddContributionModal> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedAccountName;

  final List<double> _quickAmounts = [50000, 100000, 200000, 500000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido a aportar.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    // 1. Sumar aporte a la meta
    ref.read(savingsListProvider.notifier).addContribution(widget.goal.id, amount);

    // 2. Si se seleccionó una cuenta, debitar el monto y registrar el movimiento
    final accounts = ref.read(accountListProvider);
    if (_selectedAccountName != null) {
      final match = accounts.where((a) => a.name == _selectedAccountName).toList();
      if (match.isNotEmpty) {
        final acc = match.first;
        final newBal = acc.type == AccountType.creditCard ? acc.balance + amount : acc.balance - amount;
        ref.read(accountListProvider.notifier).updateBalance(acc.id, newBal);
      }
    }

    // 3. Registrar como transacción de ahorro
    ref.read(transactionListProvider.notifier).addTransaction(
      TransactionModel(
        id: const Uuid().v4(),
        title: 'Aporte a: ${widget.goal.title}',
        amount: amount,
        type: TransactionType.expense,
        category: ExpenseCategory.savings,
        necessity: NecessityType.saving,
        accountName: _selectedAccountName ?? (accounts.isNotEmpty ? accounts.first.name : 'Efectivo'),
        date: DateTime.now(),
        tag: '#AhorroExtra',
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Aporte de ${CurrencyFormatter.formatCOP(amount)} a "${widget.goal.title}" registrado con éxito! 🎉'),
        backgroundColor: TivoColors.statusIncomeGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accounts = ref.watch(accountListProvider);

    if (_selectedAccountName == null && accounts.isNotEmpty) {
      _selectedAccountName = accounts.first.name;
    }

    final progress = (widget.goal.currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.only(top: 12),
      child: GlassCard(
        borderRadius: TivoSpacing.radiusXl,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),

              // Title & Goal Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aporte Extra / Puntual',
                          style: TextStyle(
                            color: TivoColors.primaryIceBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.goal.title,
                          style: const TextStyle(
                            color: TivoColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.goal.color.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.piggyBank, color: widget.goal.color, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(widget.goal.color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actual: ${CurrencyFormatter.formatCompact(widget.goal.currentAmount)}',
                    style: const TextStyle(color: TivoColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Meta: ${CurrencyFormatter.formatCompact(widget.goal.targetAmount)}',
                    style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Amount Input Field
              const Text(
                '¿Cuánto deseas abonar hoy?',
                style: TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: TivoColors.statusIncomeGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    borderSide: const BorderSide(color: TivoColors.statusIncomeGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Amount Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickAmounts.map((q) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _amountController.text = q.toStringAsFixed(0);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: TivoColors.statusIncomeGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                          border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          '+ ${CurrencyFormatter.formatCompact(q)}',
                          style: const TextStyle(
                            color: TivoColors.statusIncomeGreenLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Origin Account Selector (from which account is the money coming?)
              if (accounts.isNotEmpty) ...[
                const Text(
                  'Debitar desde la cuenta (Opcional):',
                  style: TextStyle(
                    color: TivoColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: accounts.map((acc) {
                      final isSelected = _selectedAccountName == acc.name;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAccountName = acc.name),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? TivoColors.primaryIceBlue.withOpacity(0.2) : Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                            border: Border.all(
                              color: isSelected ? TivoColors.primaryIceBlue : Colors.white10,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.landmark, size: 12, color: isSelected ? TivoColors.primaryIceBlue : TivoColors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                '${acc.name} (${CurrencyFormatter.formatCompact(acc.balance)})',
                                style: TextStyle(
                                  color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // CTA Button
              TivoButton(
                width: double.infinity,
                label: 'Confirmar y Abonar',
                icon: LucideIcons.checkCircle,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
