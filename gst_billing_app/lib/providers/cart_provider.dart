import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/invoice_item.dart';

class CartProvider with ChangeNotifier {
  final List<InvoiceItem> _items = [];

  List<InvoiceItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  double get totalCgst => _items.fold(0, (sum, item) => sum + item.totalCgst);

  double get totalSgst => _items.fold(0, (sum, item) => sum + item.totalSgst);

  double get totalGst => totalCgst + totalSgst;

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void addProduct(Product product, [int quantity = 1]) {
    final existingItemIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Product already exists, update quantity
      final existingItem = _items[existingItemIndex];
      final updatedQuantity = existingItem.quantity + quantity;
      _items[existingItemIndex] = InvoiceItem(
        product: existingItem.product,
        quantity: updatedQuantity,
      );
    } else {
      // Add new product
      _items.add(InvoiceItem(
        product: product,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = InvoiceItem(
        product: _items[index].product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
