import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import 'invoice_view_screen.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  late Future<List<Invoice>> _invoicesFuture;
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<Invoice> _filteredInvoices = [];
  List<Invoice> _allInvoices = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _invoicesFuture = _databaseService.getInvoices();
      _allInvoices = await _invoicesFuture;
      _filteredInvoices = List.from(_allInvoices);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && _selectedDateRange == null) {
        _filteredInvoices = List.from(_allInvoices);
      } else {
        _filteredInvoices = _allInvoices.where((invoice) {
          bool matchesQuery = true;
          if (query.isNotEmpty) {
            matchesQuery = invoice.id.toLowerCase().contains(query) ||
                (invoice.customerName != null &&
                    invoice.customerName!.toLowerCase().contains(query)) ||
                (invoice.customerPhone != null &&
                    invoice.customerPhone!.toLowerCase().contains(query));
          }

          bool matchesDateRange = true;
          if (_selectedDateRange != null) {
            final invoiceDate = DateTime(
              invoice.createdAt.year,
              invoice.createdAt.month,
              invoice.createdAt.day,
            );
            final startDate = DateTime(
              _selectedDateRange!.start.year,
              _selectedDateRange!.start.month,
              _selectedDateRange!.start.day,
            );
            final endDate = DateTime(
              _selectedDateRange!.end.year,
              _selectedDateRange!.end.month,
              _selectedDateRange!.end.day,
            );

            matchesDateRange = (invoiceDate.isAtSameMomentAs(startDate) ||
                    invoiceDate.isAfter(startDate)) &&
                (invoiceDate.isAtSameMomentAs(endDate) ||
                    invoiceDate.isBefore(endDate));
          }

          return matchesQuery && matchesDateRange;
        }).toList();
      }
    });
  }

  void _showDateRangePicker() async {
    final now = DateTime.now();
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
      _filterInvoices();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDateRange = null;
      _filteredInvoices = List.from(_allInvoices);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Invoices',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterInvoices();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_selectedDateRange == null
                            ? 'Filter by Date'
                            : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'),
                        onPressed: _showDateRangePicker,
                      ),
                    ),
                    if (_selectedDateRange != null ||
                        _searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        onPressed: _clearFilters,
                        tooltip: 'Clear Filters',
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Invoice list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInvoices.isEmpty
                    ? const Center(child: Text('No invoices found'))
                    : ListView.builder(
                        itemCount: _filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = _filteredInvoices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(
                                'Invoice #${invoice.id.substring(0, 8)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Date: ${dateFormat.format(invoice.createdAt)}'),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Items: ${invoice.items.length} | Amount: ${CurrencyFormatter.format(invoice.total)}'),
                                  if (invoice.customerName != null)
                                    Text('Customer: ${invoice.customerName}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.visibility,
                                    color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceViewScreen(
                                          invoiceId: invoice.id),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceViewScreen(
                                        invoiceId: invoice.id),
                                  ),
                                );
                              },
                              isThreeLine: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
