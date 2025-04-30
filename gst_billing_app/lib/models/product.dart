class Product {
  final String id;
  final String name;
  final double price;
  final double gstPercentage;
  final String? barcode;
  final String? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.gstPercentage,
    this.barcode,
    this.category,
  });

  // Calculate CGST
  double get cgst => (price * gstPercentage / 100) / 2;

  // Calculate SGST
  double get sgst => (price * gstPercentage / 100) / 2;

  // Calculate total price including GST
  double get totalPrice => price + cgst + sgst;

  // Convert Product to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gstPercentage': gstPercentage,
      'barcode': barcode,
      'category': category,
    };
  }

  // Create Product from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      gstPercentage: map['gstPercentage'],
      barcode: map['barcode'],
      category: map['category'],
    );
  }

  // Create a copy of Product with changes
  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? gstPercentage,
    String? barcode,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
    );
  }
}
