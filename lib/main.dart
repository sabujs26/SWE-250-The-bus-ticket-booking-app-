import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'auth_screen.dart';
import 'home_screen.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyA33jweXenSxo5Vi_p2qR3uEY3WBqAbzJQ",
  authDomain: "bus-tricket-system.firebaseapp.com",
  projectId: "bus-tricket-system",
  storageBucket: "bus-tricket-system.firebasestorage.app",
  messagingSenderId: "229729290865",
  appId: "1:229729290865:web:b9b91a6ee5a1f736fe69d0",
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticket Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomeScreen(); // Already logged in
          } else {
            return const AuthScreen(); // Not logged in
          }
        },
      ),
    );
  }
}
