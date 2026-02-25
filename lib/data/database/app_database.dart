import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';

class AppDatabase {
  static Database? _database;
  static final AppDatabase instance = AppDatabase._internal();
  
  AppDatabase._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT DEFAULT '#2196F3'
      )
    ''');
    
    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        name TEXT NOT NULL,
        category_id INTEGER,
        price REAL NOT NULL,
        cost_price REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        unit TEXT DEFAULT 'pcs',
        image_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    
    // Create suppliers table
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT,
        debt REAL DEFAULT 0
      )
    ''');
    
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        amount_paid REAL NOT NULL,
        change_amount REAL NOT NULL,
        note TEXT
      )
    ''');
    
    // Create transaction_items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    
    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    
    // Insert default categories
    for (var cat in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'color': cat['color'],
      });
    }
  }
  
  // Product operations
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }
  
  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await database;
    final results = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    final results = await db.query('products', where: 'barcode = ?', whereArgs: [barcode]);
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    final db = await database;
    return await db.query('products', where: 'category_id = ?', whereArgs: [categoryId]);
  }
  
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }
  
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('products', product);
  }
  
  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> updateProductStock(int productId, int newStock) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
  
  // Category operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }
  
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }
  
  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update('categories', category, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
  
  // Supplier operations
  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    final db = await database;
    return await db.query('suppliers', orderBy: 'name ASC');
  }
  
  Future<int> insertSupplier(Map<String, dynamic> supplier) async {
    final db = await database;
    return await db.insert('suppliers', supplier);
  }
  
  Future<int> updateSupplier(int id, Map<String, dynamic> supplier) async {
    final db = await database;
    return await db.update('suppliers', supplier, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }
  
  // Transaction operations
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'created_at DESC');
  }
  
  Future<List<Map<String, dynamic>>> getTransactionsByDate(DateTime date) async {
    final db = await database;
    final start = DateTime(date.year, date.month, date.day).toIso8601String();
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
    return await db.query(
      'transactions',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'created_at DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getTransactionsInRange(DateTime start, DateTime end) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
  }
  
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }
  
  // Transaction Items operations
  Future<List<Map<String, dynamic>>> getTransactionItems(int transactionId) async {
    final db = await database;
    return await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }
  
  Future<int> insertTransactionItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('transaction_items', item);
  }
  
  // Settings operations
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return results.isNotEmpty ? results.first['value'] as String : null;
  }
  
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Dashboard queries
  Future<double> getTodaySales() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM transactions WHERE created_at BETWEEN ? AND ?',
      [start, end],
    );
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
  
  Future<int> getTodayTransactionCount() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE created_at BETWEEN ? AND ?',
      [start, end],
    );
    
    return (result.first['count'] as int?) ?? 0;
  }
  
  Future<List<Map<String, dynamic>>> getLowStockProducts(int threshold) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'stock < ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getTopSellingProducts(int days, int limit) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    
    return await db.rawQuery('''
      SELECT 
        product_id,
        product_name,
        SUM(quantity) as total_quantity,
        SUM(subtotal) as total_sales
      FROM transaction_items
      WHERE transaction_id IN (
        SELECT id FROM transactions WHERE created_at >= ?
      )
      GROUP BY product_id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [startDate, limit]);
  }
  
  // Backup & Restore
  Future<Map<String, dynamic>> exportAllData() async {
    final products = await getAllProducts();
    final categories = await getAllCategories();
    final suppliers = await getAllSuppliers();
    
    // Remove id from products for import
    final productsWithoutId = products.map((p) {
      final map = Map<String, dynamic>.from(p);
      map.remove('id');
      map.remove('created_at');
      return map;
    }).toList();
    
    final categoriesWithoutId = categories.map((c) {
      final map = Map<String, dynamic>.from(c);
      map.remove('id');
      return map;
    }).toList();
    
    final suppliersWithoutId = suppliers.map((s) {
      final map = Map<String, dynamic>.from(s);
      map.remove('id');
      return map;
    }).toList();
    
    return {
      'products': productsWithoutId,
      'categories': categoriesWithoutId,
      'suppliers': suppliersWithoutId,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
  
  Future<void> importProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();
    
    for (var product in products) {
      batch.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }
  
  Future<void> importCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    final batch = db.batch();
    
    for (var category in categories) {
      batch.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }
}
