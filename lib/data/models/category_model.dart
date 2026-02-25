class Category {
  final int? id;
  final String name;
  final String color;
  
  Category({
    this.id,
    required this.name,
    this.color = '#2196F3',
  });
  
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String? ?? '#2196F3',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
    };
  }
  
  Category copyWith({
    int? id,
    String? name,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
