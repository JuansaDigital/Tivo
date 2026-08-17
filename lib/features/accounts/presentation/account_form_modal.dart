import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../data/account_provider.dart';
import '../domain/models/account_model.dart';

class AccountFormModal extends ConsumerStatefulWidget {
  final AccountModel? accountToEdit;

  const AccountFormModal({super.key, this.accountToEdit});

  @override
  ConsumerState<AccountFormModal> createState() => _AccountFormModalState();
}

class _AccountFormModalState extends ConsumerState<AccountFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _institutionController;
  late TextEditingController _balanceController;
  late TextEditingController _accountNumberController;
  late AccountType _selectedType;
  bool _isGMFExempt = false;

  // Credit Card specific fields
  late TextEditingController _creditLimitController;
  late TextEditingController _cutOffDayController;
  late TextEditingController _paymentDueDayController;

  @override
  void initState() {
    super.initState();
    final acc = widget.accountToEdit;
    
    _nameController = TextEditingController(text: acc?.name ?? '');
    _institutionController = TextEditingController(text: acc?.institutionName ?? '');
    _balanceController = TextEditingController(text: acc?.balance.toString() ?? '');
    _accountNumberController = TextEditingController(text: acc?.accountNumberMasked.replaceAll('•••• ', '') ?? '');
    _selectedType = acc?.type ?? AccountType.savings;
    _isGMFExempt = acc?.isGMFExempt ?? false;

    _creditLimitController = TextEditingController(text: acc?.creditLimit?.toString() ?? '');
    _cutOffDayController = TextEditingController(text: acc?.cutOffDay?.toString() ?? '');
    _paymentDueDayController = TextEditingController(text: acc?.paymentDueDay?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _balanceController.dispose();
    _accountNumberController.dispose();
    _creditLimitController.dispose();
    _cutOffDayController.dispose();
    _paymentDueDayController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final isCredit = _selectedType == AccountType.creditCard;
      
      final newAccount = AccountModel(
        id: widget.accountToEdit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        institutionName: _institutionController.text.trim(),
        type: _selectedType,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        accountNumberMasked: _selectedType == AccountType.cash 
            ? 'Efectivo Físico' 
            : '•••• ${_accountNumberController.text.trim()}',
        isGMFExempt: _isGMFExempt,
        creditLimit: isCredit ? double.tryParse(_creditLimitController.text) : null,
        cutOffDay: isCredit ? int.tryParse(_cutOffDayController.text) : null,
        paymentDueDay: isCredit ? int.tryParse(_paymentDueDayController.text) : null,
      );

      if (widget.accountToEdit != null) {
        ref.read(accountListProvider.notifier).updateAccount(newAccount);
      } else {
        ref.read(accountListProvider.notifier).addAccount(newAccount);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountToEdit != null;
    final isCredit = _selectedType == AccountType.creditCard;
    final isCash = _selectedType == AccountType.cash;

    return Container(
      decoration: const BoxDecoration(
        color: TivoColors.bgDeepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(TivoSpacing.radiusXl)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Cuenta' : 'Nueva Cuenta',
                    style: const TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                      onPressed: () {
                        ref.read(accountListProvider.notifier).deleteAccount(widget.accountToEdit!.id);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Tipo de Cuenta
              const Text('TIPO DE INSTRUMENTO', style: _labelStyle),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: AccountType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? type.color.withOpacity(0.2) : Colors.white10,
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                          border: Border.all(
                            color: isSelected ? type.color : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(type.icon, size: 16, color: isSelected ? type.color : TivoColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              _getAccountTypeName(type),
                              style: TextStyle(
                                color: isSelected ? type.color : TivoColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _nameController,
                label: 'NOMBRE DE LA CUENTA',
                hint: 'Ej: Cuenta Nómina, Tarjeta Principal...',
                icon: LucideIcons.wallet,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _institutionController,
                label: 'BANCO O INSTITUCIÓN',
                hint: 'Ej: Bancolombia, Nu, Efectivo...',
                icon: LucideIcons.building,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _balanceController,
                label: isCredit ? 'CONSUMO FACTURADO (\$)' : 'SALDO ACTUAL (\$)',
                hint: '0',
                icon: LucideIcons.dollarSign,
                isNumber: true,
              ),
              
              if (!isCash) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _accountNumberController,
                  label: 'ÚLTIMOS 4 DÍGITOS',
                  hint: 'Ej: 1234',
                  icon: LucideIcons.hash,
                  isNumber: true,
                  maxLength: 4,
                ),
              ],

              if (isCredit) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _creditLimitController,
                  label: 'CUPO TOTAL DE LA TARJETA (\$)',
                  hint: '0',
                  icon: LucideIcons.creditCard,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cutOffDayController,
                        label: 'DÍA CORTE',
                        hint: '1 al 31',
                        icon: LucideIcons.calendar,
                        isNumber: true,
                        maxLength: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _paymentDueDayController,
                        label: 'DÍA PAGO LÍM.',
                        hint: '1 al 31',
                        icon: LucideIcons.calendarClock,
                        isNumber: true,
                        maxLength: 2,
                      ),
                    ),
                  ],
                ),
              ],

              if (!isCredit && !isCash) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Cuenta Exenta de 4x1000',
                    style: TextStyle(color: TivoColors.textPrimary, fontSize: 14),
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeColor: TivoColors.statusIncomeGreen,
                  value: _isGMFExempt,
                  onChanged: (val) => setState(() => _isGMFExempt = val),
                ),
              ],
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TivoColors.primaryIceBlue,
                    foregroundColor: const Color(0xFF070E22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Guardar Cambios' : 'Crear Cuenta',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          style: const TextStyle(color: TivoColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: TivoColors.textTertiary),
            prefixIcon: Icon(icon, color: TivoColors.textTertiary, size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }
}

const _labelStyle = TextStyle(
  color: TivoColors.textTertiary,
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.0,
);

String _getAccountTypeName(AccountType type) {
  switch (type) {
    case AccountType.savings:
      return 'Ahorros';
    case AccountType.checking:
      return 'Corriente';
    case AccountType.creditCard:
      return 'T. Crédito';
    case AccountType.cash:
      return 'Bolsillo / Efectivo';
  }
}
