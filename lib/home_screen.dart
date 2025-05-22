import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bus Ticket Booking')),
      body: Padding(

        padding: EdgeInsets.all(16.0),
        child: Column(

          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text('Search Buses'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  List<Map<String, dynamic>> buses = [
                    {'name': 'HANIF', 'route': 'Dhaka to Chittagong', 'price': 500, 'boardingTime': '10:00 AM', 'droppingTime': '6:00 PM'},
                    {'name': 'ENA', 'route': 'Dhaka to Sirajgonj', 'price': 350, 'boardingTime': '9:00 AM', 'droppingTime': '3:00 PM'},
                    {'name': 'SHEBA GREEN LINE', 'route': 'Dhaka to Gopalgonj', 'price': 450, 'boardingTime': '8:00 AM', 'droppingTime': '4:00 PM'},
                    {'name': 'EMAD', 'route': 'Gopalgonj to Dhaka', 'price': 400, 'boardingTime': '7:00 AM', 'droppingTime': '5:00 PM'},
                    {'name': 'TUNGIPARA', 'route': 'Dhaka to Chittagong', 'price': 550, 'boardingTime': '11:00 AM', 'droppingTime': '7:00 PM'},
                  ];

                  var bus = buses[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Left side: Bus Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bus['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(bus['route']),
                                Text('Boarding: ${bus['boardingTime']}'),
                                Text('Dropping: ${bus['droppingTime']}'),
                              ],
                            ),
                          ),

                          // Right Side: Price & Book Now
                          Column(
                            children: [
                            
                              Container(
                                width: 80, 
                                height: 40, 
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20), 
                                ),
                                child: Center(
                                  child: Text(
                                    '৳${bus['price']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 130, 
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20), 
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SeatSelectionScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Book Now',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Working