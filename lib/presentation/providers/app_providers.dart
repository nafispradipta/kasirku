import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../models/transaction_model.dart';
import '../models/cart_item_model.dart';
import '../../core/constants/app_constants.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// Products provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.watch(databaseProvider));
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final AppDatabase _db;
  
  ProductsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _db.getAllProducts();
      state = AsyncValue.data(products.map((p) => Product.fromMap(p)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addProduct(Product product) async {
    try {
      await _db.insertProduct(product.toMap());
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateProduct(Product product) async {
    try {
      await _db.updateProduct(product.id!, product.toMap());
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteProduct(int id) async {
    try {
      await _db.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateStock(int productId, int newStock) async {
    try {
      await _db.updateProductStock(productId, newStock);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Product?> searchByBarcode(String barcode) async {
    final result = await _db.getProductByBarcode(barcode);
    return result != null ? Product.fromMap(result) : null;
  }
  
  List<Product> searchProducts(String query, List<Product> products) {
    if (query.isEmpty) return products;
    final lowerQuery = query.toLowerCase();
    return products.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) || 
      (p.barcode?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
  
  List<Product> filterByCategory(int? categoryId, List<Product> products) {
    if (categoryId == null) return products;
    return products.where((p) => p.categoryId == categoryId).toList();
  }
}

// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoriesNotifier(ref.watch(databaseProvider));
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final AppDatabase _db;
  
  CategoriesNotifier(this._db) : super(const AsyncValue.loading()) {
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _db.getAllCategories();
      state = AsyncValue.data(categories.map((c) => Category.fromMap(c)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addCategory(Category category) async {
    try {
      await _db.insertCategory(category.toMap());
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateCategory(Category category) async {
    try {
      await _db.updateCategory(category.id!, category.toMap());
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteCategory(int id) async {
    try {
      await _db.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}

// Suppliers provider
final suppliersProvider = StateNotifierProvider<SuppliersNotifier, AsyncValue<List<Supplier>>>((ref) {
  return SuppliersNotifier(ref.watch(databaseProvider));
});

class SuppliersNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final AppDatabase _db;
  
  SuppliersNotifier(this._db) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }
  
  Future<void> loadSuppliers() async {
    state = const AsyncValue.loading();
    try {
      final suppliers = await _db.getAllSuppliers();
      state = AsyncValue.data(suppliers.map((s) => Supplier.fromMap(s)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _db.insertSupplier(supplier.toMap());
      await loadSuppliers();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _db.updateSupplier(supplier.id!, supplier.toMap());
      await loadSuppliers();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteSupplier(int id) async {
    try {
      await _db.deleteSupplier(id);
      await loadSuppliers();
    } catch (e) {
      rethrow;
    }
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref _ref;
  
  CartNotifier(this._ref) : super([]);
  
  void addItem(Product product, {int quantity = 1, double discount = 0}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [
        ...state,
        CartItem(product: product, quantity: quantity, discount: discount),
      ];
    }
  }
  
  void removeItem(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }
  
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }
  
  void updateDiscount(int productId, double discount) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(discount: discount);
      }
      return item;
    }).toList();
  }
  
  void clearCart() {
    state = [];
  }
  
  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
  
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}

// Transactions provider
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref.watch(databaseProvider), ref);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final AppDatabase _db;
  final Ref _ref;
  
  TransactionsNotifier(this._db, this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }
  
  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _db.getAllTransactions();
      state = AsyncValue.data(transactions.map((t) => Transaction.fromMap(t)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<int> createTransaction({
    required double total,
    required String paymentMethod,
    required double amountPaid,
    required double change,
    String? note,
  }) async {
    try {
      // Insert transaction
      final transactionId = await _db.insertTransaction({
        'total': total,
        'payment_method': paymentMethod,
        'amount_paid': amountPaid,
        'change_amount': change,
        'note': note,
      });
      
      // Insert transaction items
      final cart = _ref.read(cartProvider);
      for (var item in cart) {
        await _db.insertTransactionItem({
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
          'subtotal': item.subtotal,
        });
        
        // Update stock
        final newStock = item.product.stock - item.quantity;
        await _db.updateProductStock(item.product.id!, newStock);
      }
      
      // Clear cart
      _ref.read(cartProvider.notifier).clearCart();
      
      // Reload data
      await loadTransactions();
      await _ref.read(productsProvider.notifier).loadProducts();
      
      return transactionId;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Transaction>> getTransactionsByDate(DateTime date) async {
    final transactions = await _db.getTransactionsByDate(date);
    return transactions.map((t) => Transaction.fromMap(t)).toList();
  }
  
  Future<List<Transaction>> getTransactionsInRange(DateTime start, DateTime end) async {
    final transactions = await _db.getTransactionsInRange(start, end);
    return transactions.map((t) => Transaction.fromMap(t)).toList();
  }
}

// Dashboard provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardData>((ref) {
  return DashboardNotifier(ref.watch(databaseProvider));
});

class DashboardData {
  final double todaySales;
  final int todayTransactions;
  final List<Product> lowStockProducts;
  final List<Map<String, dynamic>> topProducts;
  
  DashboardData({
    this.todaySales = 0,
    this.todayTransactions = 0,
    this.lowStockProducts = const [],
    this.topProducts = const [],
  });
}

class DashboardNotifier extends StateNotifier<DashboardData> {
  final AppDatabase _db;
  
  DashboardNotifier(this._db) : super(DashboardData()) {
    loadDashboard();
  }
  
  Future<void> loadDashboard() async {
    try {
      final todaySales = await _db.getTodaySales();
      final todayTransactions = await _db.getTodayTransactionCount();
      final lowStock = await _db.getLowStockProducts(AppConstants.lowStockThreshold);
      final topProducts = await _db.getTopSellingProducts(7, 10);
      
      state = DashboardData(
        todaySales: todaySales,
        todayTransactions: todayTransactions,
        lowStockProducts: lowStock.map((p) => Product.fromMap(p)).toList(),
        topProducts: topProducts,
      );
    } catch (e) {
      // Handle error silently
    }
  }
}

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, String>>((ref) {
  return SettingsNotifier(ref.watch(databaseProvider));
});

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  final AppDatabase _db;
  
  SettingsNotifier(this._db) : super({}) {
    loadSettings();
  }
  
  Future<void> loadSettings() async {
    final settings = <String, String>{
      'store_name': await _db.getSetting('store_name') ?? 'Toko Saya',
      'store_address': await _db.getSetting('store_address') ?? '',
      'store_phone': await _db.getSetting('store_phone') ?? '',
      'tax_rate': await _db.getSetting('tax_rate') ?? '0',
    };
    state = settings;
  }
  
  Future<void> setSetting(String key, String value) async {
    await _db.setSetting(key, value);
    state = {...state, key: value};
  }
}

// Selected category filter provider
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered products provider
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  return products.whenData((productList) {
    var filtered = productList;
    
    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.categoryId == selectedCategory).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(query) || 
        (p.barcode?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    return filtered;
  });
});
