import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class DatabaseService {
  static const String productBoxName = 'products';
  static const String invoiceBoxName = 'invoices';
  final uuid = const Uuid();

  // Initialize database
  Future<void> initDatabase() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(productBoxName);
    await Hive.openBox<String>(invoiceBoxName);
  }

  // Product CRUD operations
  Future<List<Product>> getProducts() async {
    final box = Hive.box<String>(productBoxName);
    return box.values
        .map((productJson) => Product.fromMap(jsonDecode(productJson)))
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    final box = Hive.box<String>(productBoxName);
    final productJson = box.get(id);
    if (productJson == null) return null;
    return Product.fromMap(jsonDecode(productJson));
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<String> addProduct(String name, double price, double gstPercentage,
      String? barcode, String? category) async {
    final box = Hive.box<String>(productBoxName);
    final id = uuid.v4();
    final product = Product(
      id: id,
      name: name,
      price: price,
      gstPercentage: gstPercentage,
      barcode: barcode,
      category: category,
    );
    await box.put(id, jsonEncode(product.toMap()));
    return id;
  }

  Future<void> updateProduct(Product product) async {
    final box = Hive.box<String>(productBoxName);
    await box.put(product.id, jsonEncode(product.toMap()));
  }

  Future<void> deleteProduct(String id) async {
    final box = Hive.box<String>(productBoxName);
    await box.delete(id);
  }

  // Invoice CRUD operations
  Future<List<Invoice>> getInvoices() async {
    final box = Hive.box<String>(invoiceBoxName);
    return box.values
        .map((invoiceJson) => Invoice.fromMap(jsonDecode(invoiceJson)))
        .toList();
  }

  Future<Invoice?> getInvoiceById(String id) async {
    final box = Hive.box<String>(invoiceBoxName);
    final invoiceJson = box.get(id);
    if (invoiceJson == null) return null;
    return Invoice.fromMap(jsonDecode(invoiceJson));
  }

  Future<String> createInvoice(
    List<InvoiceItem> items, {
    String? customerName,
    String? customerPhone,
    String? customerGstin,
  }) async {
    final box = Hive.box<String>(invoiceBoxName);
    final id = uuid.v4();
    final invoice = Invoice(
      id: id,
      createdAt: DateTime.now(),
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      customerGstin: customerGstin,
    );
    await box.put(id, jsonEncode(invoice.toMap()));
    return id;
  }

  Future<void> deleteInvoice(String id) async {
    final box = Hive.box<String>(invoiceBoxName);
    await box.delete(id);
  }
}
