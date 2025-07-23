import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const PaymentScreen({super.key, required this.bookingId, required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isPaying = false;

  Future<void> _processPayment() async {
    setState(() => _isPaying = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'paymentStatus': 'Paid'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      Navigator.pop(context, true); // Return to previous screen with success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.bookingData;

    return Scaffold(
      appBar: AppBar(title: const Text("Make Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bus: ${booking['busName'] ?? 'N/A'}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Route: ${booking['from']} → ${booking['to']}"),
            Text("Date: ${booking['date']}"),
            Text("Seats: ${(booking['selectedSeats'] ?? []).join(', ')}"),
            Text("Total: ৳${booking['totalPrice']}"),
            const SizedBox(height: 24),
            _isPaying
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processPayment,
                      icon: Icon(Icons.payment),
                      label: Text("Pay Now"),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
