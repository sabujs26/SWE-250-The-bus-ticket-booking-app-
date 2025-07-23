import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'ticket_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String userId;
  late Stream<QuerySnapshot> bookingsStream;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
    _setBookingsStream();
  }

  void _setBookingsStream() {
    bookingsStream = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingTime', descending: true)
        .snapshots();
  }

  void _refresh() {
    setState(() {
      _setBookingsStream();
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No bookings found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              itemCount: bookings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final data = booking.data() as Map<String, dynamic>? ?? {};

                final busName = data['busName'] ?? 'Bus';
                final from = data['from'] ?? 'N/A';
                final to = data['to'] ?? 'N/A';
                final seats = List<String>.from(data['selectedSeats'] ?? []);
                final seatFare = (data['seatFare'] ?? 0).toDouble();
                final totalPrice = data['totalPrice'] ?? 0;
                final paymentStatus = data['paymentStatus'] ?? 'Pending';
                final journeyDate = data['date'] ?? 'N/A';
                final boardingTime = data['boardingTime'] ?? 'N/A';
                final boardingPoint = data['boardingPoint'] ?? 'N/A';
                final droppingPoint = data['droppingPoint'] ?? 'N/A';
                final reportingTime = data['reportingTime'] ?? 'N/A';
                final bookingTime = _formatDate(data['bookingTime']);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailsScreen(
                            bookingData: {...data, 'bookingId': booking.id},
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(busName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          const SizedBox(height: 6),
                          Text('Route: $from → $to'),
                          Text('Seats: ${seats.join(', ')}'),
                          Text('Journey Date: $journeyDate'),
                          Text('Departure Time: $boardingTime'),
                          Text('Booked on: $bookingTime', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total: ৳$totalPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(paymentStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              if (paymentStatus.toLowerCase() == 'paid')
                                TextButton(
                                  onPressed: () {
                                    generateModernETicketPDF(
                                      context: context,
                                      busName: busName,
                                      from: from,
                                      to: to,
                                      departureTime: boardingTime,
                                      journeyDate: journeyDate,
                                      boardingPoint: boardingPoint,
                                      droppingPoint: droppingPoint,
                                      reportingTime: reportingTime,
                                      seats: seats,
                                      seatFare: seatFare,
                                    );
                                  },
                                  child: const Text('Download E-Ticket'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Future<void> generateModernETicketPDF({
  required BuildContext context,
  required String busName,
  required String from,
  required String to,
  required String departureTime,
  required String journeyDate,
  required String boardingPoint,
  required String droppingPoint,
  required String reportingTime,
  required List<String> seats,
  required double seatFare,
}) async {
  final pdf = pw.Document();
  final issuedOn = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  final serial = Random().nextInt(999999).toString().padLeft(6, '0');
  final totalFare = seatFare * seats.length;
  final fontData = await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf');
  final banglaFont = pw.Font.ttf(fontData);

  final userName = 'AHS MR';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue, width: 2),
            color: PdfColors.white,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ENA TRANSPORT (PVT.) LTD.', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                  pw.Text('Serial: #$serial', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Divider(),
              pw.Text('Name: $userName', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('কোচ নাম্বার: ${busName.isNotEmpty ? busName : '1100-DHK-SYLHET-DAY'}', style: pw.TextStyle(fontSize: 12, font: banglaFont)),
              pw.SizedBox(height: 4),
              pw.Text('Seat No(s): ${seats.join(', ')}'),
              pw.Text('Seat Fare: Tk. ${seatFare.toStringAsFixed(2)}'),
              pw.Text('Total Fare: Tk. ${totalFare.toStringAsFixed(2)}'),
              pw.SizedBox(height: 8),
              pw.Text('From: ${from.isNotEmpty ? from : "Dhaka"}'),
              pw.Text('To: ${to.isNotEmpty ? to : "Sylhet"}'),
              pw.Text('Departure Time: ${departureTime.isNotEmpty ? departureTime : "12:00 PM"}'),
              pw.Text('Journey Date: ${journeyDate.isNotEmpty ? journeyDate : "17 Jun 2025"}'),
              pw.SizedBox(height: 8),
              pw.Text('Boarding: ${boardingPoint.isNotEmpty ? boardingPoint : "Tongi Station Road"}'),
              pw.Text('Dropping: ${droppingPoint.isNotEmpty ? droppingPoint : "Sylhet"}'),
              pw.Text('Reporting Time: ${reportingTime.isNotEmpty ? reportingTime : "11:40 AM"}'),
              pw.SizedBox(height: 8),
              pw.Text('Issued On: $issuedOn'),
              pw.Text('Issued By: Shohoz.com'),
              pw.SizedBox(height: 4),
              pw.Text('প্রিন্ট করেছেন: Mamun (Operator)', style: pw.TextStyle(font: banglaFont, fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text('ধন্যবাদ আমাদের সাথে যাত্রা করার জন্য!', style: pw.TextStyle(fontSize: 10, font: banglaFont)),
              ),
            ],
          ),
        );
      },
    ),
  );

  final bytes = await pdf.save();

  try {
    final dir = Directory('/storage/emulated/0/Download');
    final file = File('${dir.path}/ETicket_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to Downloads')));
    await OpenFile.open(file.path);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
  }
}
