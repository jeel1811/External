import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import 'invoice_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  // Analytics data
  double _totalSales = 0;
  double _totalGst = 0;
  int _totalInvoices = 0;
  int _totalProducts = 0;

  // Period selection
  String _selectedPeriod = 'Today';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final invoices = await _databaseService.getInvoices();
      final products = await _databaseService.getProducts();

      // Filter invoices based on selected period
      final filteredInvoices = _filterInvoicesByPeriod(invoices);

      // Calculate analytics
      double totalSales = 0;
      double totalGst = 0;

      for (var invoice in filteredInvoices) {
        totalSales += invoice.total;
        totalGst += invoice.totalGst;
      }

      setState(() {
        _invoices = filteredInvoices;
        _totalSales = totalSales;
        _totalGst = totalGst;
        _totalInvoices = filteredInvoices.length;
        _totalProducts = products.length;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Invoice> _filterInvoicesByPeriod(List<Invoice> invoices) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case 'Today':
        return invoices.where((invoice) {
          final invoiceDate = DateTime(
            invoice.createdAt.year,
            invoice.createdAt.month,
            invoice.createdAt.day,
          );
          return invoiceDate.isAtSameMomentAs(today);
        }).toList();

      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return invoices.where((invoice) {
          return invoice.createdAt
              .isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
        }).toList();

      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return invoices.where((invoice) {
          return invoice.createdAt
              .isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
        }).toList();

      case 'All Time':
      default:
        return invoices;
    }
  }

  List<Invoice> _getRecentInvoices() {
    final sortedInvoices = List<Invoice>.from(_invoices);
    sortedInvoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedInvoices.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Period: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedPeriod,
                              isExpanded: true,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedPeriod = value;
                                  });
                                  _loadData();
                                }
                              },
                              items: _periods.map((period) {
                                return DropdownMenuItem<String>(
                                  value: period,
                                  child: Text(period),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sales overview
                  const Text(
                    'Sales Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Analytics cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildAnalyticsCard(
                        title: 'Total Sales',
                        value: CurrencyFormatter.format(_totalSales),
                        icon: Icons.currency_rupee,
                        color: Colors.blue,
                      ),
                      _buildAnalyticsCard(
                        title: 'Total GST',
                        value: CurrencyFormatter.format(_totalGst),
                        icon: Icons.receipt,
                        color: Colors.green,
                      ),
                      _buildAnalyticsCard(
                        title: 'Total Invoices',
                        value: _totalInvoices.toString(),
                        icon: Icons.description,
                        color: Colors.orange,
                      ),
                      _buildAnalyticsCard(
                        title: 'Total Products',
                        value: _totalProducts.toString(),
                        icon: Icons.inventory_2,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent invoices
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Invoices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const InvoiceHistoryScreen()),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _invoices.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child:
                                Text('No invoices found for selected period'),
                          ),
                        )
                      : _buildRecentInvoicesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoicesList() {
    final recentInvoices = _getRecentInvoices();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentInvoices.length,
      itemBuilder: (context, index) {
        final invoice = recentInvoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              'Invoice #${invoice.id.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Date: ${dateFormat.format(invoice.createdAt)} | Items: ${invoice.items.length}',
            ),
            trailing: Text(
              CurrencyFormatter.format(invoice.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
