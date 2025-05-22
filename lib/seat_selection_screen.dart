import 'package:flutter/material.dart';

class SeatSelectionScreen extends StatefulWidget {
  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Map<String, bool> selectedSeats = {};
  List<List<String?>> seatRows = [];
  int seatPrice = 500; 
  int maxSeatsAllowed = 4; 

  List<String> soldSeats = ['A1', 'A2', 'D1', 'D2'];

  @override
  void initState() {
    super.initState();
    // seat alignment look like a bus
    for (var row in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']) {
      seatRows.add([
        '${row}1',
        '${row}2',
        null, // Aisle space
        '${row}3',
        '${row}4'
      ]);
    }
    for (var row in seatRows) {
      for (var seat in row) {
        if (seat != null) selectedSeats[seat] = false;
      }
    }
  }

  // Calculate total selected seats
  int getTotalSelectedSeats() {
    return selectedSeats.values.where((selected) => selected).toList().length;
  }

  // Calculate total cost for seat
  int getTotalCost() {
    return getTotalSelectedSeats() * seatPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Seat')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: seatRows.length,
                itemBuilder: (context, rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: seatRows[rowIndex].map((seat) {
                      if (seat == null) {
                        return SizedBox(width: 24);
                      }

                      bool isSeatSold = soldSeats.contains(seat);
                      bool isSeatDisabled = getTotalSelectedSeats() >= maxSeatsAllowed && !(selectedSeats[seat] ?? false);

                      return GestureDetector(
                        onTap: () {
                          if (!isSeatSold && (getTotalSelectedSeats() < maxSeatsAllowed || (selectedSeats[seat] ?? false))) {
                            setState(() {
                              selectedSeats[seat] = !(selectedSeats[seat] ?? false);
                            });
                          } else if (isSeatSold) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('This seat is already sold.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else if (getTotalSelectedSeats() >= maxSeatsAllowed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('You can only select up to $maxSeatsAllowed seats.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(6),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSeatSold
                                ? Colors.orange
                                : isSeatDisabled
                                    ? Colors.grey.shade300 
                                    : (selectedSeats[seat] ?? false)
                                        ? Colors.green 
                                        : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              seat,                     // Display seat number
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            // Total seats and cost display
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Seats: ${getTotalSelectedSeats()}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Cost: ৳${getTotalCost()}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: getTotalSelectedSeats() > 0 ? () {
                      // Handle booking logic here
                    } : null,
                    child: Text('Confirm Selection'),
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
