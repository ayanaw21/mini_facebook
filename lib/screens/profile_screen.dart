import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Column(
        children: [
          Icon(Icons.person, size: 100),
          Text(user!.email!),
          Text("User ID: ${user.uid}"),
        ],
      ),
    );
  }
}
