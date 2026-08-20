import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/tivo_button.dart';
import '../../accounts/data/account_provider.dart';
import '../../accounts/domain/models/account_model.dart';
import '../data/reminders_provider.dart';
import '../domain/models/reminder_model.dart';

class PayReminderModal extends ConsumerStatefulWidget {
  final ReminderModel reminder;

  const PayReminderModal({super.key, required this.reminder});

  static Future<void> show(BuildContext context, {required ReminderModel reminder}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayReminderModal(reminder: reminder),
    );
  }

  @override
  ConsumerState<PayReminderModal> createState() => _PayReminderModalState();
}

class _PayReminderModalState extends ConsumerState<PayReminderModal> {
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  String? _selectedAccountName;
  bool _isMinimumPayment = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.reminder.estimatedAmount.toStringAsFixed(0),
    );
    _selectedDate = DateTime.now();
    _selectedAccountName = widget.reminder.defaultAccountId.isNotEmpty
        ? widget.reminder.defaultAccountId
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto de pago válido.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    final accounts = ref.read(accountListProvider);
    String targetAccountName = _selectedAccountName ??
        (accounts.isNotEmpty ? accounts.first.name : 'Bancolombia Principal');

    ref.read(reminderListProvider.notifier).payReminder(
      widget.reminder.id,
      accountName: targetAccountName,
      amountPaid: amount,
      paymentDate: _selectedDate,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pago de "${widget.reminder.title}" debitado de $targetAccountName y registrado en tus movimientos.'),
        backgroundColor: TivoColors.statusIncomeGreen,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: TivoColors.primaryIceBlue,
              onPrimary: Color(0xFF070E22),
              surface: TivoColors.bgDeepNavy,
              onSurface: TivoColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accounts = ref.watch(accountListProvider);

    if (_selectedAccountName == null && accounts.isNotEmpty) {
      _selectedAccountName = accounts.first.name;
    }

    final r = widget.reminder;
    final hasMinimumOption = r.pillar == ReminderPillar.creditDebt && r.minimumPayment != null;

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

              // Cabecera
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: r.pillar.color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(r.pillar.icon, size: 20, color: r.pillar.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pagar & Debitar Compromiso',
                          style: TextStyle(
                            color: TivoColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          r.title,
                          style: const TextStyle(
                            color: TivoColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Si es tarjeta de crédito, opciones de Pago Total vs Mínimo
              if (hasMinimumOption) ...[
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMinimumPayment = false;
                            _amountController.text = r.estimatedAmount.toStringAsFixed(0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isMinimumPayment ? TivoColors.primaryIceBlue.withOpacity(0.2) : Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            border: Border.all(
                              color: !_isMinimumPayment ? TivoColors.primaryIceBlue : Colors.white10,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Pago Total',
                                style: TextStyle(
                                  color: !_isMinimumPayment ? TivoColors.textPrimary : TivoColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(r.estimatedAmount),
                                style: TextStyle(
                                  color: !_isMinimumPayment ? TivoColors.primaryIceBlue : TivoColors.textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMinimumPayment = true;
                            _amountController.text = r.minimumPayment!.toStringAsFixed(0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isMinimumPayment ? TivoColors.statusWarningAmber.withOpacity(0.2) : Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            border: Border.all(
                              color: _isMinimumPayment ? TivoColors.statusWarningAmber : Colors.white10,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Pago Mínimo',
                                style: TextStyle(
                                  color: _isMinimumPayment ? TivoColors.textPrimary : TivoColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(r.minimumPayment!),
                                style: TextStyle(
                                  color: _isMinimumPayment ? TivoColors.statusWarningAmberLight : TivoColors.textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Campo de Monto
              const Text(
                'Monto a Pagar',
                style: TextStyle(color: TivoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(color: TivoColors.primaryIceBlue, fontSize: 24, fontWeight: FontWeight.w800),
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

              // Selector de Cuenta a Debitar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '¿De dónde se debita el pago?',
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (accounts.isEmpty)
                const Text('No hay cuentas registradas', style: TextStyle(color: TivoColors.textTertiary))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: accounts.map((acc) {
                      final isSelected = _selectedAccountName == acc.name;
                      final typeIcon = acc.type == AccountType.creditCard
                          ? LucideIcons.creditCard
                          : acc.type == AccountType.cash
                              ? LucideIcons.banknote
                              : LucideIcons.landmark;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedAccountName = acc.name),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TivoColors.primaryIceBlue.withOpacity(0.2)
                                : Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                            border: Border.all(
                              color: isSelected ? TivoColors.primaryIceBlue : Colors.white10,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(typeIcon, size: 16, color: isSelected ? TivoColors.primaryIceBlue : TivoColors.textSecondary),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    style: TextStyle(
                                      color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Saldo: ${CurrencyFormatter.formatCompact(acc.balance)}',
                                    style: const TextStyle(
                                      color: TivoColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),

              // Selector de Fecha de Pago
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fecha del Pago',
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TivoColors.primaryIceBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                        border: Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.calendar, size: 14, color: TivoColors.primaryIceBlue),
                          const SizedBox(width: 6),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              color: TivoColors.primaryIceBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón Confirmar Pago
              TivoButton(
                width: double.infinity,
                label: 'Confirmar & Debitar Pago',
                icon: LucideIcons.checkCircle,
                onPressed: _confirmPayment,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
