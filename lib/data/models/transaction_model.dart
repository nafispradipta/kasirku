class Transaction {
  final int? id;
  final DateTime createdAt;
  final double total;
  final String paymentMethod;
  final double amountPaid;
  final double change;
  final String? note;
  final List<TransactionItem>? items;
  
  Transaction({
    this.id,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    this.note,
    this.items,
  });
  
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      createdAt: DateTime.parse(map['created_at'].toString()),
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      amountPaid: (map['amount_paid'] as num).toDouble(),
      change: (map['change_amount'] as num).toDouble(),
      note: map['note'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'created_at': createdAt.toIso8601String(),
      'total': total,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': change,
      'note': note,
    };
  }
  
  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'transfer':
        return 'Transfer';
      default:
        return paymentMethod;
    }
  }
}

class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  
  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });
  
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}
