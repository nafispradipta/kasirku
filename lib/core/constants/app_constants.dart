class AppConstants {
  static const String appName = 'KasirKu';
  static const String appVersion = '1.0.0';
  
  // Currency
  static const String currency = 'Rp';
  static const String currencySymbol = 'Rp ';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentQris = 'qris';
  static const String paymentTransfer = 'transfer';
  
  // Units
  static const List<String> productUnits = ['pcs', 'pack', 'kg', 'gram', 'liter', 'ml', 'dus', 'bal'];
  
  // Stock Alert
  static const int lowStockThreshold = 10;
  
  // Database
  static const String databaseName = 'kasirku.db';
  
  // Predefined Categories
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Mie Instan', 'color': '#FF9800'},
    {'name': 'Kopi & Minuman', 'color': '#795548'},
    {'name': 'Snack', 'color': '#9C27B0'},
    {'name': 'Minuman Ringan', 'color': '#2196F3'},
    {'name': 'Sabun & Sampo', 'color': '#4CAF50'},
    {'name': 'Obat-obatan', 'color': '#F44336'},
    {'name': 'Bahan Pokok', 'color': '#FFEB3B'},
    {'name': 'Lainnya', 'color': '#607D8B'},
  ];
}
