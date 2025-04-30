import 'invoice_item.dart';

class Invoice {
  final String id;
  final DateTime createdAt;
  final List<InvoiceItem> items;
  final String? customerName;
  final String? customerPhone;
  final String? customerGstin;

  Invoice({
    required this.id,
    required this.createdAt,
    required this.items,
    this.customerName,
    this.customerPhone,
    this.customerGstin,
  });

  // Calculate total amount before tax
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  // Calculate total CGST
  double get totalCgst => items.fold(0, (sum, item) => sum + item.totalCgst);

  // Calculate total SGST
  double get totalSgst => items.fold(0, (sum, item) => sum + item.totalSgst);

  // Calculate total GST
  double get totalGst => totalCgst + totalSgst;

  // Calculate grand total
  double get total => items.fold(0, (sum, item) => sum + item.total);

  // Convert Invoice to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerGstin': customerGstin,
    };
  }

  // Create Invoice from Map
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      items:
          (map['items'] as List)
              .map((item) => InvoiceItem.fromMap(item))
              .toList(),
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerGstin: map['customerGstin'],
    );
  }
}
