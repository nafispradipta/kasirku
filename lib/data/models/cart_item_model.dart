import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  double discount;
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });
  
  double get subtotal {
    final priceAfterDiscount = product.price * (1 - discount / 100);
    return priceAfterDiscount * quantity;
  }
  
  double get priceAfterDiscount => product.price * (1 - discount / 100);
  
  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
