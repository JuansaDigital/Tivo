import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/account_model.dart';

final accountListProvider = StateNotifierProvider<AccountNotifier, List<AccountModel>>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<List<AccountModel>> {
  AccountNotifier() : super(_initialAccounts);

  static final List<AccountModel> _initialAccounts = [
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
  }

  void updateAccount(AccountModel updatedAccount) {
    state = state.map((acc) => acc.id == updatedAccount.id ? updatedAccount : acc).toList();
  }

  void deleteAccount(String id) {
    state = state.where((acc) => acc.id != id).toList();
  }

  void reset() {
    state = [];
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
  }
}
