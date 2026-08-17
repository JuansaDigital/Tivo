import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/transaction_model.dart';

final transactionListProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super(_initialTransactions);

  static final List<TransactionModel> _initialTransactions = [
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Pago Nómina Quincenal',
      amount: 4500000,
      type: TransactionType.income,
      category: ExpenseCategory.salary,
      necessity: NecessityType.saving,
      accountName: 'Bancolombia Ahorros',
      date: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Rendimientos Cuenta Alto Rendimiento',
      amount: 128000,
      type: TransactionType.income,
      category: ExpenseCategory.returns,
      necessity: NecessityType.saving,
      accountName: 'Lulo Bank Rendimientos',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Arriendo Apartamento',
      amount: 1850000,
      type: TransactionType.expense,
      category: ExpenseCategory.housing,
      necessity: NecessityType.need,
      accountName: 'Bancolombia Ahorros',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Mercado Carulla Fresh',
      amount: 385000,
      type: TransactionType.expense,
      category: ExpenseCategory.food,
      necessity: NecessityType.need,
      accountName: 'Tarjeta Visa Black',
      date: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Cena Restaurante & Cócteles',
      amount: 195000,
      type: TransactionType.expense,
      category: ExpenseCategory.entertainment,
      necessity: NecessityType.want,
      accountName: 'Tarjeta Visa Black',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Servicios Públicos (Enel + EPM)',
      amount: 245000,
      type: TransactionType.expense,
      category: ExpenseCategory.utilities,
      necessity: NecessityType.need,
      accountName: 'Bancolombia Ahorros',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
  }

  void updateTransaction(TransactionModel updatedTransaction) {
    state = state.map((t) => t.id == updatedTransaction.id ? updatedTransaction : t).toList();
  }

  void deleteTransaction(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void reset() {
    state = [];
  }
}
