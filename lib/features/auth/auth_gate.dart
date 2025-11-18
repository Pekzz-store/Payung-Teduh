import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Halaman Login & Register
import 'login_page.dart';
import 'register_page.dart';

// Import Halaman Utama (Yang punya Bottom Navigation Bar)
import '../main_page.dart'; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Memantau status login secara real-time
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Jika User Sudah Login -> Masuk ke MainPage (Menu Bawah)
        if (snapshot.hasData) {
          return const MainPage();
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