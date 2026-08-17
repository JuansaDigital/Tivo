import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Currency { COP, USD, EUR }

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.COP);

  void setCurrency(Currency currency) {
    state = currency;
  }
}
