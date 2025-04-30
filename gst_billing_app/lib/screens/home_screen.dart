import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'new_bill_screen.dart';
import 'product_list_screen.dart';
import 'invoice_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TATA Retail GST Billing'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Dashboard',
                    Icons.dashboard,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'New Bill',
                    Icons.receipt_long,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewBillScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Products',
                    Icons.inventory_2,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductListScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Invoice History',
                    Icons.history,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InvoiceHistoryScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Settings',
                    Icons.settings,
                    Colors.grey.shade700,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'About',
                    Icons.info,
                    Colors.teal,
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'GST Billing App',
                        applicationVersion: 'v1.0.0',
                        applicationIcon: const Icon(Icons.receipt_long,
                            size: 50, color: Colors.blue),
                        applicationLegalese:
                            '© 2023 TATA Retail Solutions\nAll rights reserved',
                        children: const [
                          SizedBox(height: 16),
                          Text(
                              'GST Billing App developed for TATA Retail Solutions to streamline '
                              'GST calculations, billing operations, and invoice management.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                'TATA Retail Solutions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
