import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(Product, int)? onProductScanned;

  const BarcodeScannerScreen({
    Key? key,
    this.onProductScanned,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _manualBarcodeController =
      TextEditingController();

  String _lastScannedBarcode = '';
  Product? _scannedProduct;
  bool _isLoading = false;
  bool _isScanning = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1';

    // Start scanning automatically when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _manualBarcodeController.dispose();
    super.dispose();
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      // User cancelled scanning
      if (barcode == '-1') {
        setState(() {
          _isScanning = false;
        });
        return;
      }

      _processBarcode(barcode);
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get barcode')),
      );
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processBarcode(String barcode) async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
      _lastScannedBarcode = barcode;
      _scannedProduct = null;
    });

    try {
      final product = await _databaseService.getProductByBarcode(barcode);

      setState(() {
        _scannedProduct = product;
        _isLoading = false;
      });

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found with barcode: $barcode'),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _startScanning,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _updateQuantity(int value) {
    setState(() {
      _quantity = value;
      _quantityController.text = value.toString();
    });
  }

  void _addToCart() {
    if (_scannedProduct == null) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    if (widget.onProductScanned != null) {
      widget.onProductScanned!(_scannedProduct!, quantity);
    } else {
      // If no callback is provided, just navigate back with the result
      Navigator.pop(
          context, {'product': _scannedProduct, 'quantity': quantity});
    }

    // Clear for next scan
    setState(() {
      _scannedProduct = null;
      _lastScannedBarcode = '';
      _quantity = 1;
      _quantityController.text = '1';
    });

    // Show success message and offer to scan again or return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Product added to cart'),
        action: SnackBarAction(
          label: 'Scan Another',
          onPressed: _startScanning,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _searchManualBarcode() async {
    final barcode = _manualBarcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a barcode')),
      );
      return;
    }

    _processBarcode(barcode);
    _manualBarcodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _isScanning ? null : _startScanning,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual entry
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual Barcode Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualBarcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Barcode',
                              border: OutlineInputBorder(),
                              hintText: 'Enter barcode manually',
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _searchManualBarcode,
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_isScanning) ...[
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning barcode...'),
                  ],
                ),
              ),
            ] else if (_isLoading) ...[
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching for product...'),
                  ],
                ),
              ),
            ] else if (_scannedProduct != null) ...[
              // Product details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scanned Barcode: $_lastScannedBarcode',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scannedProduct!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price: ${CurrencyFormatter.format(_scannedProduct!.price)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'GST: ${_scannedProduct!.gstPercentage}%',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Price:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                        _scannedProduct!.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quantity selection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: _quantity > 1
                                        ? () => _updateQuantity(_quantity - 1)
                                        : null,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        final parsedValue = int.tryParse(value);
                                        if (parsedValue != null &&
                                            parsedValue > 0) {
                                          setState(() {
                                            _quantity = parsedValue;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: () =>
                                        _updateQuantity(_quantity + 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addToCart,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    'Add to Cart',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_lastScannedBarcode.isNotEmpty) ...[
              // No product found with the barcode
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No product found with barcode:\n$_lastScannedBarcode',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _startScanning,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Again'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Initial state - ready to scan
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ready to Scan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the button below to scan a barcode',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _startScanning,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Start Scanning'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
