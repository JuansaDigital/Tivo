import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../data/reminders_provider.dart';
import '../domain/models/reminder_model.dart';

class ReminderFormModal extends ConsumerStatefulWidget {
  final ReminderModel? reminderToEdit;

  const ReminderFormModal({super.key, this.reminderToEdit});

  static Future<void> show(BuildContext context, {ReminderModel? reminderToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderFormModal(reminderToEdit: reminderToEdit),
    );
  }

  @override
  ConsumerState<ReminderFormModal> createState() => _ReminderFormModalState();
}

class _ReminderFormModalState extends ConsumerState<ReminderFormModal> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late ReminderPillar _selectedPillar;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final r = widget.reminderToEdit;
    _titleController = TextEditingController(text: r?.title ?? '');
    _amountController = TextEditingController(text: r?.estimatedAmount.toStringAsFixed(0) ?? '');
    _notesController = TextEditingController(text: r?.notes ?? '');
    _selectedPillar = r?.pillar ?? ReminderPillar.fixedUtility;
    _selectedDate = r?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un título y monto válidos.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    final newReminder = ReminderModel(
      id: widget.reminderToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      pillar: _selectedPillar,
      estimatedAmount: amount,
      dueDate: _selectedDate,
      defaultAccountId: widget.reminderToEdit?.defaultAccountId ?? 'bancolombia_1',
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      isPaid: widget.reminderToEdit?.isPaid ?? false,
    );

    if (widget.reminderToEdit != null) {
      ref.read(reminderListProvider.notifier).updateReminder(newReminder);
    } else {
      ref.read(reminderListProvider.notifier).addReminder(newReminder);
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
    final isEditing = widget.reminderToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: TivoColors.bgDeepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(TivoSpacing.radiusXl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio',
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
                      ref.read(reminderListProvider.notifier).deleteReminder(widget.reminderToEdit!.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _titleController,
              label: 'TÍTULO O CONCEPTO',
              hint: 'Ej: Pago Internet, Netflix...',
              icon: LucideIcons.fileText,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              label: 'MONTO ESTIMADO (\$)',
              hint: '0',
              icon: LucideIcons.dollarSign,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            
            const Text('TIPO DE COMPROMISO', style: _labelStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ReminderPillar.values.map((pillar) {
                  final isSelected = _selectedPillar == pillar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPillar = pillar),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? TivoColors.primaryIceBlue.withOpacity(0.2) : Colors.white10,
                        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                        border: Border.all(
                          color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(pillar.icon, size: 16, color: isSelected ? TivoColors.primaryIceBlue : TivoColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            pillar.label,
                            style: TextStyle(
                              color: isSelected ? TivoColors.primaryIceBlue : TivoColors.textSecondary,
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
            const SizedBox(height: 16),
            
            const Text('FECHA LÍMITE DE PAGO', style: _labelStyle),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar, color: TivoColors.textTertiary, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: TivoColors.textPrimary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'NOTAS U OBSERVACIONES',
              hint: 'Opcional...',
              icon: LucideIcons.pencil,
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TivoColors.primaryIceBlue,
                  foregroundColor: const Color(0xFF070E22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Crear Recordatorio',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: TivoColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: TivoColors.textTertiary),
            prefixIcon: Icon(icon, color: TivoColors.textTertiary, size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
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
