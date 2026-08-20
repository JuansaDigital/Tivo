import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/reminder_model.dart';
import '../domain/models/tax_shield_model.dart';

import '../../transactions/data/transaction_provider.dart';
import '../../transactions/domain/models/transaction_model.dart';

final reminderListProvider =
    StateNotifierProvider<ReminderNotifier, List<ReminderModel>>((ref) {
  return ReminderNotifier(ref);
});

class ReminderNotifier extends StateNotifier<List<ReminderModel>> {
  final Ref _ref;

  ReminderNotifier(this._ref) : super(_getInitial());

  static List<ReminderModel> _getInitial() {
    return StorageService.loadReminders();
  }

  static List<ReminderModel> get initialReminders => [
    ReminderModel(
      id: const Uuid().v4(),
      title: 'Factura Internet Fibra Óptica (Claro)',
      pillar: ReminderPillar.fixedUtility,
      estimatedAmount: 125000,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      defaultAccountId: 'Bancolombia Principal',
      notes: 'Referencia de pago: 99482103',
    ),
    ReminderModel(
      id: const Uuid().v4(),
      title: 'Tarjeta Nu Visa Platinum (Pago Total Sugerido)',
      pillar: ReminderPillar.creditDebt,
      estimatedAmount: 1450000,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      defaultAccountId: 'Bancolombia Principal',
      minimumPayment: 145000,
      interestRateEA: 0.285,
      notes: 'Paga total para evitar \$34.500 de intereses este mes',
    ),
    ReminderModel(
      id: const Uuid().v4(),
      title: 'Servicio de Energía (Enel Colombia)',
      pillar: ReminderPillar.fixedUtility,
      estimatedAmount: 185000,
      dueDate: DateTime.now().add(const Duration(days: 6)),
      defaultAccountId: 'Bancolombia Principal',
    ),
    ReminderModel(
      id: const Uuid().v4(),
      title: 'Plan Dúo Spotify & Netflix',
      pillar: ReminderPillar.subscription,
      estimatedAmount: 64900,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      defaultAccountId: 'Nu Visa Platinum',
    ),
    ReminderModel(
      id: const Uuid().v4(),
      title: 'Arriendo Apartamento',
      pillar: ReminderPillar.fixedUtility,
      estimatedAmount: 1850000,
      dueDate: DateTime.now().subtract(const Duration(days: 16)),
      isPaid: true,
      defaultAccountId: 'Bancolombia Principal',
      notes: 'Transferencia directa al propietario',
    ),
  ];

  void payReminder(
    String id, {
    required String accountName,
    required double amountPaid,
    DateTime? paymentDate,
  }) {
    final matches = state.where((r) => r.id == id).toList();
    if (matches.isEmpty) return;
    final reminder = matches.first;

    // 1. Marcar como pagado
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(isPaid: true);
      }
      return r;
    }).toList();
    StorageService.saveReminders(state);

    // 2. Mapear categoría de gasto
    ExpenseCategory category;
    switch (reminder.pillar) {
      case ReminderPillar.fixedUtility:
        final tLower = reminder.title.toLowerCase();
        if (tLower.contains('arriendo') || tLower.contains('apartamento')) {
          category = ExpenseCategory.housing;
        } else {
          category = ExpenseCategory.utilities;
        }
        break;
      case ReminderPillar.creditDebt:
        category = ExpenseCategory.other;
        break;
      case ReminderPillar.subscription:
        category = ExpenseCategory.entertainment;
        break;
    }

    // 3. Registrar movimiento financiero automático
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: 'Pago: ${reminder.title}',
      amount: amountPaid,
      type: TransactionType.expense,
      category: category,
      necessity: NecessityType.need,
      accountName: accountName,
      date: paymentDate ?? DateTime.now(),
      note: reminder.notes != null ? 'Compromiso: ${reminder.notes}' : 'Pago de recordatorio',
      tag: 'Recordatorio',
    );

    _ref.read(transactionListProvider.notifier).addTransaction(transaction);
  }

  void markAsPaid(String id) {
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(isPaid: true);
      }
      return r;
    }).toList();
    StorageService.saveReminders(state);
  }

  void addReminder(ReminderModel reminder) {
    state = [...state, reminder];
    StorageService.saveReminders(state);
  }

  void updateReminder(ReminderModel updatedReminder) {
    state = state.map((r) => r.id == updatedReminder.id ? updatedReminder : r).toList();
    StorageService.saveReminders(state);
  }

  void deleteReminder(String id) {
    state = state.where((r) => r.id != id).toList();
    StorageService.saveReminders(state);
  }

  void reset() {
    state = [];
    StorageService.saveReminders(state);
  }

  void loadDemoData() {
    state = initialReminders;
    StorageService.saveReminders(state);
  }
}

final taxShieldProvider = Provider<TaxShieldProfile>((ref) {
  return const TaxShieldProfile(
    taxYear: 2026,
    cardPurchases: TaxMetricThreshold(
      title: 'Compras Totales con Tarjetas',
      description: 'Acumulado anual de consumos electrónicos',
      currentAmount: 28450000,
      limitThreshold: 65800000,
      uvtEquivalent: '1.400 UVT (\$65.8M)',
    ),
    bankDeposits: TaxMetricThreshold(
      title: 'Consignaciones Bancarias Recibidas',
      description: 'Transferencias, nómina y abonos de terceros',
      currentAmount: 39120000,
      limitThreshold: 65800000,
      uvtEquivalent: '1.400 UVT (\$65.8M)',
    ),
    grossAssets: TaxMetricThreshold(
      title: 'Patrimonio Bruto Total',
      description: 'Suma de saldos líquidos, vehículos y activos',
      currentAmount: 82500000,
      limitThreshold: 211500000,
      uvtEquivalent: '4.500 UVT (\$211.5M)',
    ),
  );
});
