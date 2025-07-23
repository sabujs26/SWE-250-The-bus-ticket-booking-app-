import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const TicketDetailsScreen({super.key, required this.bookingData});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late String bookingId;
  Map<String, dynamic>? bookingData;
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
          bookingData = snapshot.data();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching booking: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsPaid() async {
    setState(() {
      isMarkingPaid = true;
    });
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'Paid',
    });
    await _fetchBooking();
    setState(() {
      isMarkingPaid = false;
    });
  }

  pw.Document _buildPdfDocument() {
    final pdf = pw.Document();

    final now = DateTime.now();
    final issuedDate = DateFormat('yyyy-MM-dd').format(now);
    final issuedTime = DateFormat('hh:mm a').format(now);

    final userName = 'Mr. Sabuj'; // static as requested, or get dynamically if you want

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue, width: 2),
            borderRadius: pw.BorderRadius.circular(15),
            color: PdfColors.white,
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "e-Ticket",
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.blueGrey, thickness: 2),
              pw.SizedBox(height: 10),

              // Bus Name at top with style
              pw.Text(
                bookingData!['busName'] ?? 'Bus Name',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 12),

              // Info Rows - arranged neatly
              _buildInfoRow("Passenger", userName),
              _buildInfoRow("From", bookingData!['from'] ?? 'N/A'),
              _buildInfoRow("To", bookingData!['to'] ?? 'N/A'),
              _buildInfoRow("Journey Date", bookingData!['date'] ?? 'N/A'),
              _buildInfoRow("Departure Time", bookingData!['boardingTime'] ?? 'N/A'),

              pw.SizedBox(height: 12),

              _buildInfoRow(
                "Seats",
                (List<String>.from(bookingData!['selectedSeats'] ?? bookingData!['seats'] ?? []))
                    .join(', '),
              ),

              _buildInfoRow("Seat Fare", "৳${bookingData!['totalPrice']}"),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.blueGrey, thickness: 1),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Issued Date: $issuedDate",
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    "Issued Time: $issuedTime",
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              pw.Center(
                child: pw.Text(
                  "Safe Journey!",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.green800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue900),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _openPdfPreview() {
    final pdf = _buildPdfDocument();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(pdf: pdf),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || bookingData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ticket Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final busName = bookingData!['busName'] ?? 'Unknown Bus';
    final from = bookingData!['from'] ?? 'N/A';
    final to = bookingData!['to'] ?? 'N/A';
    final date = bookingData!['date'] ?? 'N/A';
    final boardingTime = bookingData!['boardingTime'] ?? 'N/A';
    final seats = List<String>.from(bookingData!['selectedSeats'] ?? bookingData!['seats'] ?? []);
    final totalPrice = bookingData!['totalPrice'] ?? 'N/A';
    final paymentStatus = bookingData!['paymentStatus']?.toString() ?? 'Pending';

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
                  child: Text(busName,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(height: 16),
                _buildDetailRow("From", from),
                _buildDetailRow("To", to),
                _buildDetailRow("Journey Date", date),
                _buildDetailRow("Departure Time", boardingTime),
                const Divider(height: 40, thickness: 2),
                _buildDetailRow("Seats", seats.join(', ')),
                _buildDetailRow("Total Fare", "৳$totalPrice"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Payment Status: ", style: TextStyle(fontSize: 18)),
                    Chip(
                      label: Text(
                        paymentStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      backgroundColor: paymentStatus == 'Paid' ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (paymentStatus != 'Paid')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: isMarkingPaid
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                          : const Text('Pay Now', style: TextStyle(color: Colors.white)),
                      onPressed: isMarkingPaid ? null : _markAsPaid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (paymentStatus == 'Paid')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Download Ticket', style: TextStyle(color: Colors.white)),
                      onPressed: _openPdfPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
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
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final pw.Document pdf;

  const PdfPreviewScreen({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("e-Ticket Preview")),
      body: PdfPreview(
        maxPageWidth: 800, // large preview width
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: false,
        build: (format) => pdf.save(),
      ),
    );
  }
}
