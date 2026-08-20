import 'package:intl/intl.dart';
import '../providers/currency_provider.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static Currency _currentCurrency = Currency.cop;

  static void setCurrency(Currency currency) {
    _currentCurrency = currency;
  }

  static Currency get currentCurrency => _currentCurrency;

  /// Formatea un número según la moneda seleccionada
  static String format(num amount, {bool showSign = false, Currency? currency}) {
    final curr = currency ?? _currentCurrency;
    final symbol = curr.symbol;
    final formatter = NumberFormat('#,##0', curr.locale);
    final formattedNumber = formatter.format(amount.abs().round());

    if (showSign) {
      if (amount > 0) return '+$symbol $formattedNumber';
      if (amount < 0) return '-$symbol $formattedNumber';
    }
    return '$symbol $formattedNumber';
  }
  
  // Retrocompatibilidad con formatCOP existente en la app
  static String formatCOP(num amount, {bool showSign = false, Currency? currency}) =>
      format(amount, showSign: showSign, currency: currency);

  /// Formatea cantidades grandes de forma compacta ($ 1.2M, € 450K)
  static String formatCompact(num amount, {Currency? currency}) {
    final curr = currency ?? _currentCurrency;
    final compact = NumberFormat.compact(locale: curr.locale).format(amount);
    return '${curr.symbol} $compact';
  }

  /// Formatea porcentaje (ej: 11.85%)
  static String formatPercent(double percent, {int decimals = 2}) {
    return '${percent.toStringAsFixed(decimals)}%';
  }
}

