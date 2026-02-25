class Product {
  final int? id;
  final String? barcode;
  final String name;
  final int? categoryId;
  final double price;
  final double costPrice;
  final int stock;
  final String unit;
  final String? imageUrl;
  final DateTime? createdAt;
  
  Product({
    this.id,
    this.barcode,
    required this.name,
    this.categoryId,
    required this.price,
    this.costPrice = 0,
    this.stock = 0,
    this.unit = 'pcs',
    this.imageUrl,
    this.createdAt,
  });
  
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int?,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as int?) ?? 0,
      unit: map['unit'] as String? ?? 'pcs',
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] != null 
        ? DateTime.tryParse(map['created_at'].toString()) 
        : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'unit': unit,
      'image_url': imageUrl,
    };
  }
  
  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    int? categoryId,
    double? price,
    double? costPrice,
    int? stock,
    String? unit,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  bool get isLowStock => stock <= 10;
  bool get isOutOfStock => stock <= 0;
  double get profit => price - costPrice;
  double get profitMargin => costPrice > 0 ? ((price - costPrice) / price) * 100 : 0;
}
