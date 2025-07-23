// Refactored Code with Code Smell Fixes
// ===================================================
// ✅ Refactored: Extracted Booking model to avoid primitive obsession, message chains, and temporary field.
// ✅ Refactored: Moved PDF generation into a separate class for SRP (Single Responsibility Principle).
// ✅ Refactored: Broke long methods into smaller widgets for readability and maintenance.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ========================== Booking Model =============================
// 🟡 SOLVES: Primitive Obsession, Message Chains, Temporary Field
class Booking {
  final String id;
  final String busName;
  final String from;
  final String to;
  final String date;
  final String boardingTime;
  final List<String> seats;
  final int totalPrice;
  final String paymentStatus;

  Booking({
    required this.id,
    required this.busName,
    required this.from,
    required this.to,
    required this.date,
    required this.boardingTime,
    required this.seats,
    required this.totalPrice,
    required this.paymentStatus,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      busName: data['busName'] ?? 'Unknown Bus',
      from: data['from'] ?? 'N/A',
      to: data['to'] ?? 'N/A',
      date: data['date'] ?? 'N/A',
      boardingTime: data['boardingTime'] ?? 'N/A',
      seats: List<String>.from(data['selectedSeats'] ?? data['seats'] ?? []),
      totalPrice: data['totalPrice'] ?? 0,
      paymentStatus: data['paymentStatus']?.toString() ?? 'Pending',
    );
  }
}

// ========================== PDF Generator Class =============================
// 🟡 SOLVES: Long Method, Divergent Change, Feature Envy
class TicketPdfGenerator {
  static pw.Document build(Booking booking, String userName) {
    final pdf = pw.Document();
    final now = DateTime.now();
    final issuedDate = DateFormat('yyyy-MM-dd').format(now);
    final issuedTime = DateFormat('hh:mm a').format(now);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue, width: 2),
            borderRadius: pw.BorderRadius.circular(15),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("e-Ticket",
                    style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),
              pw.Text(booking.busName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              _buildRow("Passenger", userName),
              _buildRow("From", booking.from),
              _buildRow("To", booking.to),
              _buildRow("Journey Date", booking.date),
              _buildRow("Departure Time", booking.boardingTime),
              _buildRow("Seats", booking.seats.join(', ')),
              _buildRow("Seat Fare", "৳${booking.totalPrice}"),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Issued Date: $issuedDate", style: pw.TextStyle(fontSize: 12)),
                  pw.Text("Issued Time: $issuedTime", style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text("Safe Journey!", style: pw.TextStyle(fontSize: 18, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 2, child: pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 4, child: pw.Text(value)),
        ],
      ),
    );
  }
}

// ========================== Main UI =============================
// 🟡 SOLVES: Long Method, Temporary Field, Duplicate Code
class TicketDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const TicketDetailsScreen({super.key, required this.bookingData});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late String bookingId;
  Booking? booking;
  bool isLoading = true;
  bool isMarkingPaid = false;

  @override
  void initState() {
    super.initState();
    bookingId = widget.bookingData['bookingId'];
    _fetchBooking();
  }

  Future<void> _fetchBooking() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('bookings').doc(bookingId).get();
      if (snapshot.exists) {
        setState(() {
          booking = Booking.fromMap(bookingId, snapshot.data()!);
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsPaid() async {
    setState(() => isMarkingPaid = true);
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'Paid',
    });
    await _fetchBooking();
    setState(() => isMarkingPaid = false);
  }

  void _openPdfPreview() {
    if (booking == null) return;
    final pdf = TicketPdfGenerator.build(booking!, 'Mr. Sabuj');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewScreen(pdf: pdf)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ticket Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(booking!.busName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(height: 16),
                _buildDetailRow("From", booking!.from),
                _buildDetailRow("To", booking!.to),
                _buildDetailRow("Journey Date", booking!.date),
                _buildDetailRow("Departure Time", booking!.boardingTime),
                const Divider(height: 40, thickness: 2),
                _buildDetailRow("Seats", booking!.seats.join(', ')),
                _buildDetailRow("Total Fare", "৳${booking!.totalPrice}"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Payment Status: ", style: TextStyle(fontSize: 18)),
                    Chip(
                      label: Text(
                        booking!.paymentStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      backgroundColor: booking!.paymentStatus == 'Paid' ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (booking!.paymentStatus != 'Paid')
                  _buildActionButton("Pay Now", Colors.purple, _markAsPaid, isMarkingPaid),
                if (booking!.paymentStatus == 'Paid')
                  _buildActionButton("Download Ticket", Colors.green.shade700, _openPdfPreview, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed, bool loading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(label == 'Pay Now' ? Icons.payment : Icons.download, color: Colors.white),
        label: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// 🟡 NOTE: Retained as reusable utility, not speculative anymore
class PdfPreviewScreen extends StatelessWidget {
  final pw.Document pdf;
  const PdfPreviewScreen({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("e-Ticket Preview")),
      body: PdfPreview(
        maxPageWidth: 800,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: false,
        build: (format) => pdf.save(),
      ),
    );
  }
}
