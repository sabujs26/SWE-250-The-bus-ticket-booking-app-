import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ticket_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> busInfo;

  SeatSelectionScreen({required this.busInfo});

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Map<String, bool> selectedSeats = {};
  List<List<String?>> seatRows = [];
  int seatPrice = 500;
  int maxSeatsAllowed = 4;

  List<String> soldSeats = [];
  bool isLoadingSoldSeats = true;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();

    // Define seat rows with a center aisle (null)
    for (var row in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']) {
      seatRows.add([
        '${row}1',
        '${row}2',
        null,
        '${row}3',
        '${row}4',
      ]);
    }

    for (var row in seatRows) {
      for (var seat in row) {
        if (seat != null) selectedSeats[seat] = false;
      }
    }

    seatPrice = widget.busInfo['price'] ?? 500; // Update seat price based on bus
    _loadSoldSeats();
  }

  Future<void> _loadSoldSeats() async {
    setState(() => isLoadingSoldSeats = true);
    try {
      final fromCity = widget.busInfo['route'].split(' to ')[0];
      final toCity = widget.busInfo['route'].split(' to ')[1];

      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('busName', isEqualTo: widget.busInfo['name'])
          .where('from', isEqualTo: fromCity)
          .where('to', isEqualTo: toCity)
          .where('boardingTime', isEqualTo: widget.busInfo['boardingTime'])
          .get();

      final bookedSeats = <String>[];
      for (var doc in snapshot.docs) {
        final seats = doc.data()['selectedSeats'];
        if (seats != null && seats is List) {
          bookedSeats.addAll(List<String>.from(seats));
        }
      }

      setState(() {
        soldSeats = bookedSeats.toSet().toList();
      });
    } catch (e) {
      print('Error loading sold seats: $e');
    } finally {
      setState(() => isLoadingSoldSeats = false);
    }
  }

  int getTotalSelectedSeats() => selectedSeats.values.where((s) => s).length;
  int getTotalCost() => getTotalSelectedSeats() * seatPrice;

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book seats.')),
      );
      return;
    }

    final selected =
        selectedSeats.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }

    setState(() {
      isBooking = true;
    });

    final fromCity = widget.busInfo['route'].split(' to ')[0];
    final toCity = widget.busInfo['route'].split(' to ')[1];
    final bookingTime = DateTime.now();

    final bookingData = {
      'busName': widget.busInfo['name'],
      'from': fromCity,
      'to': toCity,
      'date': bookingTime.toIso8601String().split('T')[0], // only date part
      'boardingTime': widget.busInfo['boardingTime'],
      'selectedSeats': selected,
      'totalPrice': getTotalCost(),
      'paymentStatus': 'Pending',
      'userId': user.uid,
      'bookingTime': bookingTime,
    };

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      setState(() {
        isBooking = false;
        selectedSeats.updateAll((key, value) => false);
      });

      // Navigate directly to TicketDetailsScreen after booking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(
            bookingData: {
              ...bookingData,
              'bookingId': docRef.id,
            },
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book seats: $e')),
      );
    }
  }

  Widget _buildSeat(String seatId) {
    final isSold = soldSeats.contains(seatId);
    final isSelected = selectedSeats[seatId] ?? false;
    final isDisabled = getTotalSelectedSeats() >= maxSeatsAllowed && !isSelected;

    Color bgColor;
    IconData icon;
    String tooltip;

    if (isSold) {
      bgColor = Colors.red.shade400;
      icon = Icons.event_seat;
      tooltip = 'Sold';
    } else if (isSelected) {
      bgColor = Colors.blue.shade600;
      icon = Icons.event_seat;
      tooltip = 'Selected';
    } else {
      bgColor = Colors.green.shade400;
      icon = Icons.event_seat_outlined;
      tooltip = 'Available';
    }

    return Tooltip(
      message: '$seatId - $tooltip',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.yellowAccent.shade700, width: 3)
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSold) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This seat is already sold.')),
              );
              return;
            }
            if (isDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('You can select up to $maxSeatsAllowed seats only.')),
              );
              return;
            }
            setState(() {
              selectedSeats[seatId] = !isSelected;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${isSelected ? 'Deselected' : 'Selected'} seat $seatId'),
                duration: const Duration(milliseconds: 900),
              ),
            );
          },
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
            ],
          ),
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingSoldSeats) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Your Seat'),
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Seat'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: seatRows.length,
                itemBuilder: (context, index) {
                  final row = seatRows[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((seat) {
                      if (seat == null) return const SizedBox(width: 24);
                      return _buildSeat(seat);
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.green.shade400, 'Available'),
                _buildLegendItem(Colors.blue.shade600, 'Selected'),
                _buildLegendItem(Colors.red.shade400, 'Sold'),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Seats: ${getTotalSelectedSeats()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white)),
                      Text('Total Cost: ৳${getTotalCost()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.yellowAccent)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: getTotalSelectedSeats() > 0 && !isBooking
                        ? _confirmBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black87,
                      elevation: 5,
                      shadowColor: Colors.black54,
                    ),
                    child: isBooking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text(
                            'Confirm Selection',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
