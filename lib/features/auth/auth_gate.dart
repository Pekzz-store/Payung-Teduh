import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Halaman Login & Register
import 'login_page.dart';
import 'register_page.dart';

// Import Halaman Utama (Yang punya Bottom Navigation Bar)
import '../main_page.dart';
// Import Admin Dashboard
import '../admin/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Memantau status login secara real-time
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Jika User Sudah Login -> Periksa role di Firestore
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Stream ke dokumen user untuk membaca field 'role'
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final doc = userSnapshot.data!;
              final data = doc.data() as Map<String, dynamic>?;
              final role = data?['role'] as String? ?? 'user';
              if (role == 'admin') {
                return const AdminDashboard();
              }
              return const MainPage();
            },
          );
        }

        // 2. Jika Belum Login -> Tampilkan Toggle Login/Register
        return const AuthToggle();
      },
    );
  }
}

// Widget Logika Tukar Halaman Login <-> Register
class AuthToggle extends StatefulWidget {
  const AuthToggle({super.key});

  @override
  State<AuthToggle> createState() => _AuthToggleState();
}

class _AuthToggleState extends State<AuthToggle> {
  bool showLogin = true;

  void toggle() => setState(() => showLogin = !showLogin);

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginPage(onSwitchToRegister: toggle);
    } else {
      return RegisterPage(onSwitchToLogin: toggle);
    }
  }
}
