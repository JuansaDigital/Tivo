import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Currency {
  cop('COP (\$)'),
  usd('USD (\$)'),
  eur('EUR (€)');

  final String label;
  const Currency(this.label);
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.cop);

  void setCurrency(Currency currency) {
    state = currency;
  }
}
