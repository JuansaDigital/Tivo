import 'package:flutter_test/flutter_test.dart';
import 'package:tivo/core/utils/currency_formatter.dart';
import 'package:tivo/features/accounts/domain/models/account_model.dart';

void main() {
  group('Accounts & Currency Formatter Tests', () {
    test('CurrencyFormatter formatCOP positions \$ sign at start', () {
      final formatted = CurrencyFormatter.formatCOP(1250000);
      expect(formatted, '\$ 1.250.000');
    });

    test('CurrencyFormatter formatCompact formats properly', () {
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
  });
}
