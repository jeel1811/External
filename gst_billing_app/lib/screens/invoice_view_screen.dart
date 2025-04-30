import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';

class InvoiceViewScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceViewScreen({Key? key, required this.invoiceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Invoice',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality not implemented yet')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Invoice',
            onPressed: () async {
              final invoice = await databaseService.getInvoiceById(invoiceId);
              if (invoice != null) {
                _printInvoice(context, invoice);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to load invoice')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Invoice?>(
        future: databaseService.getInvoiceById(invoiceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final invoice = snapshot.data;
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(invoice, theme),
                _buildCustomerInfo(invoice, theme),
                _buildItemsTable(invoice, theme),
                _buildSummary(invoice, theme),
                _buildFooter(theme),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _printInvoice(context, invoice);
                          },
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Share functionality not implemented yet')),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Invoice invoice, ThemeData theme) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    return Container(
      width: double.infinity,
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'TATA Retail Solutions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Center(
            child: Text(
              'GST Invoice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Invoice No:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text(invoice.id, style: const TextStyle(color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Date & Time:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white70)),
                  Text(dateFormat.format(invoice.createdAt),
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Invoice invoice, ThemeData theme) {
    if (invoice.customerName == null &&
        invoice.customerPhone == null &&
        invoice.customerGstin == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              if (invoice.customerName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text('Name: ${invoice.customerName}'),
                    ],
                  ),
                ),
              if (invoice.customerPhone != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 8),
                      Text('Phone: ${invoice.customerPhone}'),
                    ],
                  ),
                ),
              if (invoice.customerGstin != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.numbers, size: 16),
                      const SizedBox(width: 8),
                      Text('GSTIN: ${invoice.customerGstin}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTable(Invoice invoice, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(3), // Item
                  1: FlexColumnWidth(1), // Qty
                  2: FlexColumnWidth(2), // Price
                  3: FlexColumnWidth(1), // GST%
                  4: FlexColumnWidth(2), // Amount
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer),
                    children: [
                      _tableHeader('Item', theme),
                      _tableHeader('Qty', theme),
                      _tableHeader('Price', theme),
                      _tableHeader('GST%', theme),
                      _tableHeader('Amount', theme),
                    ],
                  ),
                  for (var item in invoice.items)
                    TableRow(
                      children: [
                        _tableCell(item.product.name, theme),
                        _tableCell(item.quantity.toString(), theme),
                        _tableCell(CurrencyFormatter.format(item.product.price),
                            theme),
                        _tableCell('${item.product.gstPercentage}%', theme),
                        _tableCell(CurrencyFormatter.format(item.total), theme),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildSummary(Invoice invoice, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              _summaryRow('Subtotal:',
                  CurrencyFormatter.format(invoice.subtotal), theme),
              _summaryRow(
                  'CGST:', CurrencyFormatter.format(invoice.totalCgst), theme),
              _summaryRow(
                  'SGST:', CurrencyFormatter.format(invoice.totalSgst), theme),
              const Divider(),
              _summaryRow(
                  'Total:', CurrencyFormatter.format(invoice.total), theme,
                  isTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Thank you for shopping with us!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16),
              SizedBox(width: 4),
              Text('support@tataretail.com'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context, Invoice invoice) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'TATA Retail Solutions',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'GST Invoice',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice No:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.id),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date & Time:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(dateFormat.format(invoice.createdAt)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Customer details if available
              if (invoice.customerName != null ||
                  invoice.customerPhone != null ||
                  invoice.customerGstin != null)
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Customer Details',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      if (invoice.customerName != null)
                        pw.Text('Name: ${invoice.customerName}'),
                      if (invoice.customerPhone != null)
                        pw.Text('Phone: ${invoice.customerPhone}'),
                      if (invoice.customerGstin != null)
                        pw.Text('GSTIN: ${invoice.customerGstin}'),
                    ],
                  ),
                ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Text(
                'Items',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Item
                  1: const pw.FlexColumnWidth(1), // Qty
                  2: const pw.FlexColumnWidth(2), // Price
                  3: const pw.FlexColumnWidth(1), // GST%
                  4: const pw.FlexColumnWidth(2), // Amount
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _pdfTableHeader('Item'),
                      _pdfTableHeader('Qty'),
                      _pdfTableHeader('Price'),
                      _pdfTableHeader('GST%'),
                      _pdfTableHeader('Amount'),
                    ],
                  ),
                  for (var item in invoice.items)
                    pw.TableRow(
                      children: [
                        _pdfTableCell(item.product.name),
                        _pdfTableCell(item.quantity.toString()),
                        _pdfTableCell(
                            CurrencyFormatter.format(item.product.price)),
                        _pdfTableCell('${item.product.gstPercentage}%'),
                        _pdfTableCell(CurrencyFormatter.format(item.total)),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('Subtotal:'),
                        pw.SizedBox(width: 20),
                        pw.Text(CurrencyFormatter.format(invoice.subtotal)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('CGST:'),
                        pw.SizedBox(width: 20),
                        pw.Text(CurrencyFormatter.format(invoice.totalCgst)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('SGST:'),
                        pw.SizedBox(width: 20),
                        pw.Text(CurrencyFormatter.format(invoice.totalSgst)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text('Total:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 20),
                        pw.Text(CurrencyFormatter.format(invoice.total),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for shopping with us!',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('For queries, contact: support@tataretail.com'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _pdfTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _pdfTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
