import 'product.dart';

class InvoiceItem {
  final Product product;
  final int quantity;

  InvoiceItem({required this.product, required this.quantity});

  // Calculate total price for this invoice item
  double get subtotal => product.price * quantity;

  // Calculate total CGST for this invoice item
  double get totalCgst => product.cgst * quantity;

  // Calculate total SGST for this invoice item
  double get totalSgst => product.sgst * quantity;

  // Calculate total price including GST for this invoice item
  double get total => product.totalPrice * quantity;

  // Convert InvoiceItem to Map
  Map<String, dynamic> toMap() {
    return {'product': product.toMap(), 'quantity': quantity};
  }

  // Create InvoiceItem from Map
  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'],
    );
  }
}
