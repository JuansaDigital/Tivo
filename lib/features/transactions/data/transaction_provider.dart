import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../accounts/data/account_provider.dart';
import '../../accounts/domain/models/account_model.dart';
import '../domain/models/transaction_model.dart';

final transactionListProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(_getInitial());

  static List<TransactionModel> _getInitial() {
    final stored = StorageService.loadTransactions();
    if (stored.isNotEmpty) return stored;
    StorageService.saveTransactions(initialTransactions);
    return initialTransactions;
  }

  static List<TransactionModel> get initialTransactions => [
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

  void _syncAccountBalance({
    required String? accountName,
    required double amount,
    required TransactionType type,
    required bool isReversion,
  }) {
    if (accountName == null || accountName.isEmpty) return;
    final accounts = _ref.read(accountListProvider);
    final match = accounts.where((a) =>
        a.name.toLowerCase() == accountName.toLowerCase() ||
        '${a.institutionName} ${a.name}'.toLowerCase().contains(accountName.toLowerCase())
    ).toList();
    if (match.isEmpty) return;

    final targetAccount = match.first;
    double newBalance = targetAccount.balance;

    if (type == TransactionType.expense || type == TransactionType.fixedCost) {
      if (targetAccount.type == AccountType.creditCard) {
        newBalance += isReversion ? -amount : amount;
      } else {
        newBalance += isReversion ? amount : -amount;
      }
    } else if (type == TransactionType.income) {
      newBalance += isReversion ? -amount : amount;
    }

    _ref.read(accountListProvider.notifier).updateBalance(targetAccount.id, newBalance);
  }

  void addTransaction(TransactionModel transaction) {
    _syncAccountBalance(
      accountName: transaction.accountName,
      amount: transaction.amount,
      type: transaction.type,
      isReversion: false,
    );
    state = [transaction, ...state];
    StorageService.saveTransactions(state);
  }

  void updateTransaction(TransactionModel updatedTransaction) {
    final matches = state.where((item) => item.id == updatedTransaction.id).toList();
    if (matches.isNotEmpty) {
      final oldT = matches.first;
      // Revertir impacto previo
      _syncAccountBalance(
        accountName: oldT.accountName,
        amount: oldT.amount,
        type: oldT.type,
        isReversion: true,
      );
    }
    // Aplicar nuevo impacto
    _syncAccountBalance(
      accountName: updatedTransaction.accountName,
      amount: updatedTransaction.amount,
      type: updatedTransaction.type,
      isReversion: false,
    );
    state = state.map((t) => t.id == updatedTransaction.id ? updatedTransaction : t).toList();
    StorageService.saveTransactions(state);
  }

  void deleteTransaction(String id) {
    final matches = state.where((item) => item.id == id).toList();
    if (matches.isNotEmpty) {
      final t = matches.first;
      _syncAccountBalance(
        accountName: t.accountName,
        amount: t.amount,
        type: t.type,
        isReversion: true,
      );
    }
    state = state.where((item) => item.id != id).toList();
    StorageService.saveTransactions(state);
  }

  void reset() {
    state = [];
    StorageService.saveTransactions(state);
  }

  void loadDemoData() {
    state = initialTransactions;
    StorageService.saveTransactions(state);
  }
}

