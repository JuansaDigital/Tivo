import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/tivo_button.dart';
import '../data/transaction_provider.dart';
import '../domain/models/transaction_model.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionModal({super.key, this.transactionToEdit});

  static Future<void> show(BuildContext context, {TransactionModel? transactionToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(transactionToEdit: transactionToEdit),
    );
  }

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TransactionType _type;
  late ExpenseCategory _category;
  late NecessityType _necessity;
  late String _selectedAccount;

  final List<String> _accounts = [
    'Bancolombia Ahorros',
    'Tarjeta Visa Black',
    'Nu Bank Ahorros',
    'Lulo Bank Rendimientos',
    'Efectivo',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transactionToEdit;
    _amountController = TextEditingController(text: t?.amount.toStringAsFixed(0) ?? '');
    _titleController = TextEditingController(text: t?.title ?? '');
    _type = t?.type ?? TransactionType.expense;
    _category = t?.category ?? ExpenseCategory.food;
    _necessity = t?.necessity ?? NecessityType.need;
    _selectedAccount = t?.accountName ?? _accounts.first;
    if (!_accounts.contains(_selectedAccount)) {
      _accounts.add(_selectedAccount);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido y una descripción.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    final newTransaction = TransactionModel(
      id: widget.transactionToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      necessity: _necessity,
      accountName: _selectedAccount,
      date: widget.transactionToEdit?.date ?? DateTime.now(),
    );

    if (widget.transactionToEdit != null) {
      ref.read(transactionListProvider.notifier).updateTransaction(newTransaction);
    } else {
      ref.read(transactionListProvider.notifier).addTransaction(newTransaction);
    }
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transacción "${newTransaction.title}" registrada exitosamente.'),
        backgroundColor: TivoColors.statusIncomeGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
              // Barra de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (widget.transactionToEdit != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar Movimiento',
                      style: TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                      onPressed: () {
                        ref.read(transactionListProvider.notifier).deleteTransaction(widget.transactionToEdit!.id);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Selector de Tipo (Gasto vs Ingreso)
              Row(
                children: [
                  Expanded(
                    child: _TypeSelectorButton(
                      label: 'Gasto',
                      icon: LucideIcons.arrowUpRight,
                      isSelected: _type == TransactionType.expense,
                      selectedColor: TivoColors.statusExpenseRose,
                      onTap: () => setState(() => _type = TransactionType.expense),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeSelectorButton(
                      label: 'Ingreso',
                      icon: LucideIcons.arrowDownLeft,
                      isSelected: _type == TransactionType.income,
                      selectedColor: TivoColors.statusIncomeGreen,
                      onTap: () => setState(() => _type = TransactionType.income),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo de Monto
              const Text(
                'Monto (COP)',
                style: TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: TivoColors.primaryIceBlue,
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
                    borderSide: const BorderSide(color: TivoColors.primaryIceBlue, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Descripción
              const Text(
                'Concepto / Comercio',
                style: TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ej: Mercado, Almuerzo, Uber...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
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
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Categoría
              const Text(
                'Categoría',
                style: TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ExpenseCategory.values.map((cat) {
                    final isSelected = _category == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                          border: Border.all(
                            color: isSelected ? cat.color : Colors.white10,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 14, color: isSelected ? cat.color : TivoColors.textSecondary),
                            const SizedBox(width: 5),
                            Text(
                              cat.label,
                              style: TextStyle(
                                color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                                fontSize: 12,
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
              const SizedBox(height: 16),

              // Selector de Cuenta
              const Text(
                'Cuenta Origen / Destino',
                style: TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _accounts.map((acc) {
                    final isSelected = _selectedAccount == acc;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAccount = acc),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                          acc,
                          style: TextStyle(
                            color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Necesidad (Neuroeconomía)
              if (_type == TransactionType.expense) ...[
                const Text(
                  'Clasificación Neurofinanciera',
                  style: TextStyle(
                    color: TivoColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: NecessityType.values.map((nec) {
                    final isSelected = _necessity == nec;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _necessity = nec),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (nec == NecessityType.want
                                    ? TivoColors.statusExpenseRose.withOpacity(0.2)
                                    : TivoColors.primaryIceBlue.withOpacity(0.2))
                                : Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? (nec == NecessityType.want
                                      ? TivoColors.statusExpenseRose
                                      : TivoColors.primaryIceBlue)
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            nec.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Botón Guardar
              TivoButton(
                width: double.infinity,
                label: 'Guardar Transacción',
                icon: LucideIcons.check,
                onPressed: _save,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelectorButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeSelectorButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.18) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? selectedColor : TivoColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
