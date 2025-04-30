import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings values
  bool _isDarkMode = false;
  String _businessName = 'TATA Retail Solutions';
  String _businessPhone = '';
  String _businessAddress = '';
  String _businessGstin = '';
  bool _enableBarcodeScanner = true;
  bool _autoPrintInvoice = false;

  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessGstinController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    _businessGstinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _businessName =
            prefs.getString('businessName') ?? 'TATA Retail Solutions';
        _businessPhone = prefs.getString('businessPhone') ?? '';
        _businessAddress = prefs.getString('businessAddress') ?? '';
        _businessGstin = prefs.getString('businessGstin') ?? '';
        _enableBarcodeScanner = prefs.getBool('enableBarcodeScanner') ?? true;
        _autoPrintInvoice = prefs.getBool('autoPrintInvoice') ?? false;

        _businessNameController.text = _businessName;
        _businessPhoneController.text = _businessPhone;
        _businessAddressController.text = _businessAddress;
        _businessGstinController.text = _businessGstin;

        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('businessName', _businessNameController.text);
      await prefs.setString('businessPhone', _businessPhoneController.text);
      await prefs.setString('businessAddress', _businessAddressController.text);
      await prefs.setString('businessGstin', _businessGstinController.text);
      await prefs.setBool('enableBarcodeScanner', _enableBarcodeScanner);
      await prefs.setBool('autoPrintInvoice', _autoPrintInvoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Settings
                    const Text(
                      'Display Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme for the app'),
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Business Details
                    const Text(
                      'Business Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _businessNameController,
                              decoration: const InputDecoration(
                                labelText: 'Business Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _businessPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Business Phone',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _businessAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Business Address',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _businessGstinController,
                              decoration: const InputDecoration(
                                labelText: 'Business GSTIN',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // App Settings
                    const Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Enable Barcode Scanner'),
                            subtitle: const Text(
                                'Use camera to scan product barcodes'),
                            value: _enableBarcodeScanner,
                            onChanged: (value) {
                              setState(() {
                                _enableBarcodeScanner = value;
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('Auto Print Invoice'),
                            subtitle: const Text(
                                'Automatically print invoice after generation'),
                            value: _autoPrintInvoice,
                            onChanged: (value) {
                              setState(() {
                                _autoPrintInvoice = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Settings',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // App Info
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                'GST Billing App for TATA Retail Solutions'),
                            const Text('Version: 1.0.0'),
                            const SizedBox(height: 8),
                            const Text(
                              '© 2023 TATA Retail Solutions. All rights reserved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
    );
  }
}
