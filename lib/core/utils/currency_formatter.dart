import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  static final NumberFormat _currencyFormatDecimal = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );
  
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }
  
  static String formatWithDecimal(double amount) {
    return _currencyFormatDecimal.format(amount);
  }
  
  static double parse(String value) {
    try {
      String cleanValue = value.replaceAll('Rp ', '').replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleanValue);
    } catch (e) {
      return 0;
    }
  }
  
  static String formatInput(String value) {
    try {
      double number = double.parse(value.replaceAll('.', ''));
      return _currencyFormat.format(number);
    } catch (e) {
      return value;
    }
  }
}
