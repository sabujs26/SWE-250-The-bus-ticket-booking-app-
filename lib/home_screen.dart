import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'seat_selection_screen.dart';
import 'my_bookings_screen.dart';
import 'user_profile_screen.dart';  // <-- Added import for user profile screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  DateTime? selectedDate;

  // Popular cities for autocomplete suggestions
  final List<String> popularCities = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Sylhet',
    'Khulna',
    'Barishal',
    'Comilla',
    'Rangpur',
    'Mymensingh',
    'Tangail',
    'Narayanganj',
    'Bogura',
  ];

  List<Map<String, dynamic>> allBuses = [
    {
      'name': 'HANIF',
      'route': 'Dhaka to Chittagong',
      'price': 500,
      'boardingTime': '10:00 AM',
      'droppingTime': '6:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 1)),
        DateTime.now().add(Duration(days: 3)),
      ],
    },
    {
      'name': 'ENA',
      'route': 'Dhaka to Sirajgonj',
      'price': 350,
      'boardingTime': '9:00 AM',
      'droppingTime': '3:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 2)),
      ],
    },
    {
      'name': 'SHEBA GREEN LINE',
      'route': 'Dhaka to Gopalgonj',
      'price': 450,
      'boardingTime': '8:00 AM',
      'droppingTime': '4:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 1)),
        DateTime.now().add(Duration(days: 5)),
      ],
    },
    {
      'name': 'EMAD',
      'route': 'Gopalgonj to Dhaka',
      'price': 400,
      'boardingTime': '7:00 AM',
      'droppingTime': '5:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 1)),
        DateTime.now().add(Duration(days: 7)),
      ],
    },
    {
      'name': 'TUNGIPARA',
      'route': 'Dhaka to Chittagong',
      'price': 550,
      'boardingTime': '11:00 AM',
      'droppingTime': '7:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 2)),
        DateTime.now().add(Duration(days: 4)),
      ],
    },
    {
      'name': 'SHYAMOLI',
      'route': 'Dhaka to Rajshahi',
      'price': 600,
      'boardingTime': '12:00 PM',
      'droppingTime': '8:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 3)),
      ],
    },
    {
      'name': 'SUNDARBAN',
      'route': 'Dhaka to Khulna',
      'price': 550,
      'boardingTime': '6:00 AM',
      'droppingTime': '2:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 1)),
        DateTime.now().add(Duration(days: 6)),
      ],
    },
    {
      'name': 'NILAMBOR',
      'route': 'Sylhet to Dhaka',
      'price': 600,
      'boardingTime': '8:00 AM',
      'droppingTime': '3:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 1)),
      ],
    },
    {
      'name': 'SR Travels',
      'route': 'Rajshahi to Dhaka',
      'price': 580,
      'boardingTime': '7:30 AM',
      'droppingTime': '2:30 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 2)),
      ],
    },
    {
      'name': 'Dolphin',
      'route': 'Khulna to Dhaka',
      'price': 620,
      'boardingTime': '9:00 AM',
      'droppingTime': '4:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 3)),
        DateTime.now().add(Duration(days: 5)),
      ],
    },
    {
      'name': 'Green Line',
      'route': 'Comilla to Dhaka',
      'price': 400,
      'boardingTime': '6:00 AM',
      'droppingTime': '11:00 AM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 4)),
      ],
    },
    {
      'name': 'Shyamoli Paribahan',
      'route': 'Rangpur to Dhaka',
      'price': 700,
      'boardingTime': '10:00 AM',
      'droppingTime': '6:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 2)),
        DateTime.now().add(Duration(days: 3)),
      ],
    },
    {
      'name': 'Ena Transport',
      'route': 'Barishal to Dhaka',
      'price': 480,
      'boardingTime': '7:00 AM',
      'droppingTime': '1:30 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 6)),
      ],
    },
    {
      'name': 'Meghna Paribahan',
      'route': 'Mymensingh to Dhaka',
      'price': 350,
      'boardingTime': '5:30 AM',
      'droppingTime': '10:00 AM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 1)),
      ],
    },
    {
      'name': 'Saudia Paribahan',
      'route': 'Tangail to Dhaka',
      'price': 300,
      'boardingTime': '8:00 AM',
      'droppingTime': '11:00 AM',
      'dates': [
        DateTime.now().add(Duration(days: 3)),
        DateTime.now().add(Duration(days: 7)),
      ],
    },
    {
      'name': 'Hanif Enterprise',
      'route': 'Bogura to Dhaka',
      'price': 650,
      'boardingTime': '9:30 AM',
      'droppingTime': '5:00 PM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 5)),
      ],
    },
    {
      'name': 'Lalmonirhat Express',
      'route': 'Lalmonirhat to Dhaka',
      'price': 670,
      'boardingTime': '6:00 AM',
      'droppingTime': '3:00 PM',
      'dates': [
        DateTime.now().add(Duration(days: 1)),
        DateTime.now().add(Duration(days: 4)),
      ],
    },
    {
      'name': 'Narayanganj Express',
      'route': 'Narayanganj to Dhaka',
      'price': 280,
      'boardingTime': '5:00 AM',
      'droppingTime': '6:00 AM',
      'dates': [
        DateTime.now(),
        DateTime.now().add(Duration(days: 2)),
      ],
    },
  ];

  List<Map<String, dynamic>> filteredBuses = [];

  @override
  void initState() {
    super.initState();
    filteredBuses = List.from(allBuses);

    fromController.addListener(_filterBuses);
    toController.addListener(_filterBuses);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void _signOut(BuildContext context) async {
    await _auth.signOut();
  }

  void _showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final user = _auth.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter current password' : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter new password';
                  if (value.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final cred = EmailAuthProvider.credential(
                      email: user!.email!, password: _currentPasswordController.text);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(_newPasswordController.text);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                }
              }
            },
            child: Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _passwordController = TextEditingController();
    final _newEmailController = TextEditingController();
    final user = _auth.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Email'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter current password' : null,
              ),
              TextFormField(
                controller: _newEmailController,
                decoration: InputDecoration(labelText: 'New Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter new email';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter valid email';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final cred = EmailAuthProvider.credential(
                      email: user!.email!, password: _passwordController.text);
                  await user.reauthenticateWithCredential(cred);
                  await user.updateEmail(_newEmailController.text);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update email: $e')),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _filterBuses(); // filter on date change as well
      });
    }
  }

  void _filterBuses() {
    final fromText = fromController.text.toLowerCase();
    final toText = toController.text.toLowerCase();

    setState(() {
      filteredBuses = allBuses.where((bus) {
        final route = bus['route'].toString().toLowerCase();

        final fromMatch = fromText.isEmpty || route.contains(fromText);
        final toMatch = toText.isEmpty || route.contains(toText);

        bool dateMatch = true;
        if (selectedDate != null) {
          dateMatch = bus['dates'].any((date) =>
              date.year == selectedDate!.year &&
              date.month == selectedDate!.month &&
              date.day == selectedDate!.day);
        }

        return fromMatch && toMatch && dateMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> busNameColors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.blueAccent,
      Colors.green,
      Colors.redAccent,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Ticket Booking'),
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfileScreen()),
                );
                break;

              case 'bookings':
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => MyBookingsScreen()));
                break;

              case 'change_password':
                _showChangePasswordDialog(context);
                break;

              case 'update_email':
                _showUpdateEmailDialog(context);
                break;

              case 'logout':
                _signOut(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'profile', child: Text('User Profile')),
            PopupMenuItem(value: 'bookings', child: Text('My Bookings')),
            PopupMenuItem(value: 'change_password', child: Text('Change Password')),
            PopupMenuItem(value: 'update_email', child: Text('Update Email')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FROM field with autocomplete suggestions
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return popularCities.where((city) => city
                    .toLowerCase()
                    .startsWith(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: fromController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'From',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                );
              },
              onSelected: (String selection) {
                fromController.text = selection;
                _filterBuses();
              },
            ),
            SizedBox(height: 10),

            // TO field with autocomplete suggestions
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return popularCities.where((city) => city
                    .toLowerCase()
                    .startsWith(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: toController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'To',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                );
              },
              onSelected: (String selection) {
                toController.text = selection;
                _filterBuses();
              },
            ),
            SizedBox(height: 10),

            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(selectedDate == null
                  ? 'Select Date'
                  : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'),
              onPressed: () => _pickDate(context),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _filterBuses,
              child: Text('Search Buses'),
            ),
            SizedBox(height: 20),

            Expanded(
              child: filteredBuses.isEmpty
                  ? Center(child: Text('No buses found.'))
                  : ListView.builder(
                      itemCount: filteredBuses.length,
                      itemBuilder: (context, index) {
                        final bus = filteredBuses[index];
                        final color = busNameColors[index % busNameColors.length];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Bus Icon
                                Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.directions_bus,
                                    size: 40,
                                    color: Colors.blueAccent,
                                  ),
                                ),

                                // Bus details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bus['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: color,
                                        ),
                                      ),
                                      Text(bus['route']),
                                      Text('Boarding: ${bus['boardingTime']}'),
                                      Text('Dropping: ${bus['droppingTime']}'),
                                    ],
                                  ),
                                ),

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
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.red),
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
                                                builder: (_) =>
                                                    SeatSelectionScreen(busInfo: bus),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Book Now',
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 12),
                                          ),
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero),
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
