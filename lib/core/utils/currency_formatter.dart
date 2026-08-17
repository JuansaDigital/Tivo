import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'es_CO');

  /// Formatea un número según la moneda seleccionada
  static String format(num amount, {bool showSign = false, String symbol = '\$'}) {
    final formattedNumber = _numberFormat.format(amount.abs().round()).replaceAll(',', '.');
    if (showSign) {
      if (amount > 0) return '+$symbol $formattedNumber';
      if (amount < 0) return '-$symbol $formattedNumber';
    }
    return '$symbol $formattedNumber';
  }
  
  // Retrocompatibilidad
  static String formatCOP(num amount, {bool showSign = false}) => format(amount, showSign: showSign, symbol: '\$');

  /// Formatea cantidades grandes de forma compacta (\$ 1.2M, \$ 450K)
  static String formatCompact(num amount) {
    final compact = NumberFormat.compact(locale: 'es_CO').format(amount);
    return '\$ $compact';
  }

  /// Formatea porcentaje (ej: 11.85%)
  static String formatPercent(double percent, {int decimals = 2}) {
    return '${percent.toStringAsFixed(decimals)}%';
  }
}
