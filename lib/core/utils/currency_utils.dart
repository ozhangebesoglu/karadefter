import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₺';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ₺';
    } else {
      return formatCurrency(amount);
    }
  }

  static double parseCurrency(String value) {
    // Remove currency symbol and spaces
    final cleanValue = value.replaceAll(RegExp(r'[₺\s]'), '');

    // Replace comma with dot for decimal
    final normalizedValue = cleanValue.replaceAll(',', '.');

    return double.tryParse(normalizedValue) ?? 0.0;
  }

  static bool isValidCurrency(String value) {
    final amount = parseCurrency(value);
    return amount > 0;
  }
}
