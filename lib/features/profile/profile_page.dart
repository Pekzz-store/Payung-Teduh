import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
// Import Service Tema
import '../../services/theme_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Jika user belum login, tampilkan widget kosong
    if (user == null) return const SizedBox();

    // Cek apakah tema yang sedang aktif adalah Dark Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Akun Saya"), 
        centerTitle: true, 
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          // Tampilkan loading jika data belum siap
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String name = userData?['username'] ?? 'User';
          String email = userData?['email'] ?? user.email!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Avatar Besar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    // Warna background avatar menyesuaikan tema
                    backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blue[100],
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?", 
                      style: const TextStyle(
                        fontSize: 40, 
                        color: Colors.blueAccent, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(email, style: const TextStyle(color: Colors.grey)),
                
                const SizedBox(height: 40),
                
                // --- MENU SETTINGS ---
                
                // 1. Tombol Switch Mode Gelap
                Container(
                  decoration: BoxDecoration(
                    // Warna container menyesuaikan tema (Gelap/Terang)
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    title: const Text("Mode Gelap"),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                    value: isDarkMode,
                    onChanged: (val) {
                      // Panggil fungsi ganti tema
                      ThemeService.toggleTheme(val);
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // 2. Tombol Keluar
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () {
                       AuthService().logout();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}