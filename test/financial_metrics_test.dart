import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tivo/core/providers/currency_provider.dart';
import 'package:tivo/core/providers/language_provider.dart';
import 'package:tivo/core/services/storage_service.dart';
import 'package:tivo/core/utils/currency_formatter.dart';
import 'package:tivo/core/providers/auth_provider.dart';
import 'package:tivo/core/providers/profile_provider.dart';
import 'package:tivo/core/services/auth_service.dart';
import 'package:tivo/features/accounts/data/account_provider.dart';
import 'package:tivo/features/accounts/domain/models/account_model.dart';
import 'package:tivo/features/reminders/data/reminders_provider.dart';
import 'package:tivo/features/transactions/data/transaction_provider.dart';
import 'package:tivo/features/transactions/domain/models/transaction_model.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('Accounts & Currency Formatter Tests', () {
    test('CurrencyFormatter formatCOP positions \$ sign at start', () {
      CurrencyFormatter.setCurrency(Currency.cop);
      final formatted = CurrencyFormatter.formatCOP(1250000);
      expect(formatted, '\$ 1.250.000');
    });

    test('CurrencyFormatter switches dynamically between USD, EUR and COP', () {
      CurrencyFormatter.setCurrency(Currency.usd);
      expect(CurrencyFormatter.format(5000), '\$ 5,000');

      CurrencyFormatter.setCurrency(Currency.eur);
      expect(CurrencyFormatter.format(5000), '€ 5.000');

      CurrencyFormatter.setCurrency(Currency.cop);
      expect(CurrencyFormatter.format(5000), '\$ 5.000');
    });

    test('CurrencyFormatter formatCompact formats properly', () {
      CurrencyFormatter.setCurrency(Currency.cop);
      final compact = CurrencyFormatter.formatCompact(1500000);
      expect(compact.contains('1,5'), isTrue);
    });

    test('AccountModel credit utilization calculation', () {
      const card = AccountModel(
        id: '1',
        name: 'Visa Gold',
        institutionName: 'Banco',
        type: AccountType.creditCard,
        balance: 1500000,
        creditLimit: 6000000,
        accountNumberMasked: '•••• 1234',
      );

      expect(card.creditUtilization, 0.25);
      expect(card.availableCredit, 4500000.0);
    });

    test('Preferences persistence in StorageService', () async {
      await StorageService.saveLanguage('en');
      expect(StorageService.loadLanguage(), 'en');

      await StorageService.saveCurrency('usd');
      expect(StorageService.loadCurrency(), 'usd');

      await StorageService.saveAutoLockDuration('5 minutos');
      expect(StorageService.loadAutoLockDuration(), '5 minutos');

      await StorageService.saveBiometricEnabled(false);
      expect(StorageService.loadBiometricEnabled(), false);

      await StorageService.saveUserPin('4321');
      expect(StorageService.loadUserPin(), '4321');
    });

    test('Language translations dictionary', () {
      expect(translate(AppLanguage.es, 'settings_title'), 'Configuraciones');
      expect(translate(AppLanguage.en, 'settings_title'), 'Settings');
      expect(translate(AppLanguage.es, 'cashflow_title'), 'Flujo de Caja Real');
      expect(translate(AppLanguage.en, 'cashflow_title'), 'Real Cash Flow');
    });

    test('TransactionNotifier synchronizes account balance on Add, Update and Delete', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialAccounts = container.read(accountListProvider);
      expect(initialAccounts.isNotEmpty, isTrue);

      final savingsAccount = initialAccounts.firstWhere((a) => a.name == 'Bancolombia Principal');
      final initialBalance = savingsAccount.balance;

      // 1. Agregar un gasto
      final expenseTx = TransactionModel(
        id: 'test_tx_1',
        title: 'Supermercado Test',
        amount: 200000,
        type: TransactionType.expense,
        category: ExpenseCategory.food,
        necessity: NecessityType.need,
        accountName: 'Bancolombia Principal',
        date: DateTime(2026, 8, 15, 10, 30),
      );

      container.read(transactionListProvider.notifier).addTransaction(expenseTx);

      final updatedAccountsAfterAdd = container.read(accountListProvider);
      final updatedSavings = updatedAccountsAfterAdd.firstWhere((a) => a.name == 'Bancolombia Principal');
      expect(updatedSavings.balance, initialBalance - 200000);

      // 2. Comprobar sincronización con fecha de calendario
      final txList = container.read(transactionListProvider);
      final aug15Tx = txList.where((t) => isSameDay(t.date, DateTime(2026, 8, 15))).toList();
      expect(aug15Tx.any((t) => t.id == 'test_tx_1'), isTrue);

      // 3. Eliminar gasto y verificar restauración de saldo
      container.read(transactionListProvider.notifier).deleteTransaction('test_tx_1');
      final updatedAccountsAfterDelete = container.read(accountListProvider);
      final restoredSavings = updatedAccountsAfterDelete.firstWhere((a) => a.name == 'Bancolombia Principal');
      expect(restoredSavings.balance, initialBalance);
    });

    test('ReminderNotifier payReminder marks as paid, debits account, and records transaction', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final accounts = container.read(accountListProvider);
      final bancolombia = accounts.firstWhere((a) => a.name == 'Bancolombia Principal');
      final initialBalance = bancolombia.balance;

      final reminders = container.read(reminderListProvider);
      expect(reminders.isNotEmpty, isTrue);

      final pending = reminders.firstWhere((r) => !r.isPaid);
      final reminderId = pending.id;
      final expectedAmount = pending.estimatedAmount;

      // Pagar el recordatorio seleccionando cuenta Bancolombia Principal
      container.read(reminderListProvider.notifier).payReminder(
        reminderId,
        accountName: 'Bancolombia Principal',
        amountPaid: expectedAmount,
        paymentDate: DateTime(2026, 8, 20),
      );

      // 1. Verificar que el recordatorio está marcado como pagado
      final updatedReminders = container.read(reminderListProvider);
      final paidReminder = updatedReminders.firstWhere((r) => r.id == reminderId);
      expect(paidReminder.isPaid, isTrue);

      // 2. Verificar que se debitó de la cuenta
      final updatedAccounts = container.read(accountListProvider);
      final updatedBancolombia = updatedAccounts.firstWhere((a) => a.name == 'Bancolombia Principal');
      expect(updatedBancolombia.balance, initialBalance - expectedAmount);

      // 3. Verificar que se creó la transacción en el historial de movimientos
      final transactions = container.read(transactionListProvider);
      final paymentTx = transactions.where((t) => t.title.contains(pending.title)).toList();
      expect(paymentTx.isNotEmpty, isTrue);
      expect(paymentTx.first.amount, expectedAmount);
      expect(paymentTx.first.accountName, 'Bancolombia Principal');
      expect(isSameDay(paymentTx.first.date, DateTime(2026, 8, 20)), isTrue);
    });

    test('UserProfileModel & userProfileProvider onboarding, editing and persistence', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state: not completed
      final initialProfile = container.read(userProfileProvider);
      expect(initialProfile.isCompleted, isFalse);

      // Complete profile onboarding
      container.read(userProfileProvider.notifier).completeProfile(
        name: 'Camila Morales',
        email: 'camila.morales@tivo.app',
        avatarIconId: 'gem',
        avatarColorIndex: 1, // Emerald
      );

      final updatedProfile = container.read(userProfileProvider);
      expect(updatedProfile.isCompleted, isTrue);
      expect(updatedProfile.name, 'Camila Morales');
      expect(updatedProfile.firstName, 'Camila');
      expect(updatedProfile.initials, 'CM');
      expect(updatedProfile.avatarIconId, 'gem');
      expect(updatedProfile.gradientColors.isNotEmpty, isTrue);

      // Verify persistence in StorageService
      final persisted = StorageService.loadUserProfile();
      expect(persisted, isNotNull);
      expect(persisted!.name, 'Camila Morales');
      expect(persisted.email, 'camila.morales@tivo.app');
      expect(persisted.avatarIconId, 'gem');

      // Edit profile
      container.read(userProfileProvider.notifier).updateProfile(
        name: 'Camila M. Gómez',
        avatarIconId: 'crown',
      );

      final editedProfile = container.read(userProfileProvider);
      expect(editedProfile.name, 'Camila M. Gómez');
      expect(editedProfile.avatarIconId, 'crown');
      expect(editedProfile.email, 'camila.morales@tivo.app');
    });

    test('AuthService & authStateProvider Google Sign-In, Email Sign-Up and Account Deletion', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(authStateProvider), isNull);

      // 1. Google Sign In
      await container.read(authStateProvider.notifier).signInWithGoogle(
        googleEmail: 'alex.inversiones@gmail.com',
        googleDisplayName: 'Alex Inversiones',
      );

      final googleUser = container.read(authStateProvider);
      expect(googleUser, isNotNull);
      expect(googleUser!.email, 'alex.inversiones@gmail.com');
      expect(googleUser.displayName, 'Alex Inversiones');
      expect(googleUser.providerType, AuthProviderType.google);

      // Sincronización automática de perfil
      final profileAfterGoogle = container.read(userProfileProvider);
      expect(profileAfterGoogle.email, 'alex.inversiones@gmail.com');
      expect(profileAfterGoogle.name, 'Alex Inversiones');

      // 2. Sign Out
      await container.read(authStateProvider.notifier).signOut();
      expect(container.read(authStateProvider), isNull);

      // 3. Email Sign Up
      await container.read(authStateProvider.notifier).signUpWithEmail(
        name: 'Laura Finanzas',
        email: 'laura@tivo.app',
        password: 'password123',
        avatarIconId: 'rocket',
        avatarColorIndex: 2,
      );

      final emailUser = container.read(authStateProvider);
      expect(emailUser, isNotNull);
      expect(emailUser!.email, 'laura@tivo.app');
      expect(emailUser.displayName, 'Laura Finanzas');
      expect(emailUser.providerType, AuthProviderType.email);

      // 4. Delete Account
      await container.read(authStateProvider.notifier).deleteAccount();
      expect(container.read(authStateProvider), isNull);
      expect(container.read(userProfileProvider).isCompleted, isFalse);
    });
  });
}


