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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(invoice),
                const SizedBox(height: 24),
                _buildCustomerInfo(invoice),
                const SizedBox(height: 24),
                _buildItemsTable(invoice),
                const SizedBox(height: 24),
                _buildSummary(invoice),
                const SizedBox(height: 32),
                _buildFooter(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _printInvoice(context, invoice);
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Invoice invoice) {
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'TATA Retail Solutions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Center(
          child: Text(
            'GST Invoice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invoice No:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(invoice.id),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Date & Time:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(dateFormat.format(invoice.createdAt)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(Invoice invoice) {
    if (invoice.customerName == null &&
        invoice.customerPhone == null &&
        invoice.customerGstin == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (invoice.customerName != null)
              Text('Name: ${invoice.customerName}'),
            if (invoice.customerPhone != null)
              Text('Phone: ${invoice.customerPhone}'),
            if (invoice.customerGstin != null)
              Text('GSTIN: ${invoice.customerGstin}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    _tableHeader('Item'),
                    _tableHeader('Qty'),
                    _tableHeader('Price'),
                    _tableHeader('GST%'),
                    _tableHeader('Amount'),
                  ],
                ),
                for (var item in invoice.items)
                  TableRow(
                    children: [
                      _tableCell(item.product.name),
                      _tableCell(item.quantity.toString()),
                      _tableCell(CurrencyFormatter.format(item.product.price)),
                      _tableCell('${item.product.gstPercentage}%'),
                      _tableCell(CurrencyFormatter.format(item.total)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSummary(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(CurrencyFormatter.format(invoice.subtotal)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CGST:'),
                Text(CurrencyFormatter.format(invoice.totalCgst)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SGST:'),
                Text(CurrencyFormatter.format(invoice.totalSgst)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyFormatter.format(invoice.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Thank you for shopping with us!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text('For queries, contact: support@tataretail.com'),
      ],
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
