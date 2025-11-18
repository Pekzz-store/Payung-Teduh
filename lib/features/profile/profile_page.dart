import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: true, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String name = userData?['username'] ?? 'User';
          String email = userData?['email'] ?? user.email!;

          return Column(
            children: [
              const SizedBox(height: 30),
              // Avatar Besar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[100],
                  child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 20),
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(email, style: TextStyle(color: Colors.grey[600])),
              
              const SizedBox(height: 40),
              
              // Menu Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.red)),
                onTap: () {
                   AuthService().logout();
                   // Navigasi ditangani AuthGate otomatis
                },
              ),
            ],
          );
        },
      ),
    );
  }
}