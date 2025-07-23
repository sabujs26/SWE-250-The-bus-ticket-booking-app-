import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingConfirmationScreen({super.key, required this.bookingData});

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;

  Future<void> saveBooking(Map<String, dynamic> bookingData) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final bookingWithUser = {
      ...bookingData,
      'userId': user.uid,
      'bookingTime': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('bookings').add(bookingWithUser);
  }

  void _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      await saveBooking(widget.bookingData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed! Please pay at counter.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.bookingData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['busName'] ?? 'Bus',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                ),
                const SizedBox(height: 18),
                _buildDetailRow('Route', '${booking['from']} → ${booking['to']}'),
                _buildDetailRow('Date', booking['date']),
                _buildDetailRow('Boarding Time', booking['boardingTime']),
                const SizedBox(height: 16),
                _buildDetailRow('Seats', (booking['selectedSeats'] ?? []).join(', ')),
                _buildDetailRow(
                  'Total Price',
                  '৳${booking['totalPrice']}',
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmBooking,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue.shade700,
                            elevation: 3,
                          ),
                          child: const Text(
                            'Confirm Booking',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
