import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/account_model.dart';

final accountListProvider = StateNotifierProvider<AccountNotifier, List<AccountModel>>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<List<AccountModel>> {
  AccountNotifier() : super(StorageService.loadAccounts());

  static List<AccountModel> get initialAccounts => [
    AccountModel(
      id: const Uuid().v4(),
      name: 'Bancolombia Principal',
      institutionName: 'Bancolombia',
      type: AccountType.savings,
      balance: 5450000,
      isGMFExempt: true,
      accountNumberMasked: '•••• 8921',
    ),
    AccountModel(
      id: const Uuid().v4(),
      name: 'Nu Visa Platinum',
      institutionName: 'Nubank',
      type: AccountType.creditCard,
      balance: 1450000,
      creditLimit: 6000000,
      cutOffDay: 15,
      paymentDueDay: 5,
      accountNumberMasked: '•••• 3302',
    ),
    AccountModel(
      id: const Uuid().v4(),
      name: 'Lulo Cuenta Alto Rendimiento',
      institutionName: 'Lulo Bank',
      type: AccountType.savings,
      balance: 8200000,
      isGMFExempt: false,
      accountNumberMasked: '•••• 1190',
    ),
    AccountModel(
      id: const Uuid().v4(),
      name: 'Bolsillo Emergencias',
      institutionName: 'Efectivo',
      type: AccountType.cash,
      balance: 650000,
      accountNumberMasked: 'Efectivo Físico',
    ),
  ];

  void addAccount(AccountModel account) {
    state = [...state, account];
    StorageService.saveAccounts(state);
  }

  void updateAccount(AccountModel updatedAccount) {
    state = state.map((acc) => acc.id == updatedAccount.id ? updatedAccount : acc).toList();
    StorageService.saveAccounts(state);
  }

  void deleteAccount(String id) {
    state = state.where((acc) => acc.id != id).toList();
    StorageService.saveAccounts(state);
  }

  void reset() {
    state = [];
    StorageService.saveAccounts(state);
  }

  void loadDemoData() {
    state = initialAccounts;
    StorageService.saveAccounts(state);
  }

  void updateBalance(String id, double newBalance) {
    state = state.map((acc) {
      if (acc.id == id) {
        return AccountModel(
          id: acc.id,
          name: acc.name,
          institutionName: acc.institutionName,
          type: acc.type,
          balance: newBalance,
          creditLimit: acc.creditLimit,
          cutOffDay: acc.cutOffDay,
          paymentDueDay: acc.paymentDueDay,
          isGMFExempt: acc.isGMFExempt,
          accountNumberMasked: acc.accountNumberMasked,
        );
      }
      return acc;
    }).toList();
    StorageService.saveAccounts(state);
  }
}
