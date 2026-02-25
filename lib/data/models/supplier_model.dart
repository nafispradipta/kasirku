class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final double debt;
  
  Supplier({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.debt = 0,
  });
  
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      debt: (map['debt'] as num?)?.toDouble() ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'debt': debt,
    };
  }
  
  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    double? debt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      debt: debt ?? this.debt,
    );
  }
  
  bool get hasDebt => debt > 0;
}
