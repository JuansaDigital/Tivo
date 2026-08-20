import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

enum Currency {
  cop('COP (\$)', '\$', 'es_CO', 'cop'),
  usd('USD (\$)', '\$', 'en_US', 'usd'),
  eur('EUR (€)', '€', 'es_ES', 'eur');

  final String label;
  final String symbol;
  final String locale;
  final String code;

  const Currency(this.label, this.symbol, this.locale, this.code);

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code.toLowerCase() == code.toLowerCase(),
      orElse: () => Currency.cop,
    );
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(_initialCurrency()) {
    CurrencyFormatter.setCurrency(state);
  }

  static Currency _initialCurrency() {
    final savedCode = StorageService.loadCurrency();
    return Currency.fromCode(savedCode);
  }

  void setCurrency(Currency currency) {
    state = currency;
    CurrencyFormatter.setCurrency(currency);
    StorageService.saveCurrency(currency.code);
  }
}

