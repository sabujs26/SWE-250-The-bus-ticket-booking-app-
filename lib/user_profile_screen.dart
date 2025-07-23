import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Profile')),
        body: Center(child: Text('No user logged in')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user!.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('User ID: ${user!.uid}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email Verified: ${user!.emailVerified ? "Yes" : "No"}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
