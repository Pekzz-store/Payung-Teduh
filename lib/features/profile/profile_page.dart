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

    // Fungsi pembungkus untuk ListTile agar lebih rapi
    Widget _buildSettingsTile({
      required IconData icon,
      required String title,
      Color? iconColor,
      VoidCallback? onTap,
      Widget? trailing,
      bool isLogout = false,
      bool isSwitch = false,
      bool switchValue = false,
      ValueChanged<bool>? onSwitchChanged,
    }) {
      // Tombol Switch Mode Gelap adalah kasus khusus
      if (isSwitch) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: SwitchListTile(
            title: Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            secondary: Icon(
              icon,
              color:
                  iconColor ?? (isDarkMode ? Colors.white70 : Colors.grey[800]),
            ),
            value: switchValue,
            onChanged: onSwitchChanged,
          ),
        );
      }

      // Tombol List Normal
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color:
                iconColor ?? (isDarkMode ? Colors.white70 : Colors.grey[800]),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout
                  ? Colors.red
                  : (isDarkMode ? Colors.white : Colors.black87),
              fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing:
              trailing ??
              (isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 18)),
          onTap:
              onTap ??
              () {
                // Snackbar default jika onTap tidak disediakan (untuk menu yang belum diimplementasikan)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigasi ke halaman $title')),
                );
              },
        ),
      );
    }

    // Fungsi untuk membuat header kategori
    Widget _buildCategoryHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // --- Avatar & Info User (Tidak Diubah) ---
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: isDarkMode
                            ? Colors.blueGrey[900]
                            : Colors.blue[100],
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ===================================
                // --- KATEGORI MENU PENGATURAN ---
                // ===================================

                // -----------------------------------
                // KATEGORI 1: PENGATURAN AKUN
                // -----------------------------------
                _buildCategoryHeader("Pengaturan Akun"),

                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: "Edit Profil",
                  iconColor: Colors.blue,
                ),

                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: "Ganti Kata Sandi",
                  iconColor: Colors.orange,
                ),

                // -----------------------------------
                // KATEGORI 2: LAYANAN PAYUNG
                // -----------------------------------
                _buildCategoryHeader("Layanan Payung"),

                _buildSettingsTile(
                  icon: Icons.credit_card,
                  title: "Metode Pembayaran",
                  iconColor: Colors.green,
                ),

                _buildSettingsTile(
                  icon: Icons.notifications_none,
                  title: "Pengaturan Notifikasi",
                  iconColor: Colors.redAccent,
                ),

                // -----------------------------------
                // KATEGORI 3: PENGATURAN APLIKASI
                // -----------------------------------
                _buildCategoryHeader("Tampilan & Bahasa"),

                // Mode Gelap (Menggunakan SwitchListTile)
                _buildSettingsTile(
                  icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  title: "Mode Gelap",
                  iconColor: Colors.purple,
                  isSwitch: true,
                  switchValue: isDarkMode,
                  onSwitchChanged: (val) {
                    ThemeService.toggleTheme(val);
                  },
                ),

                _buildSettingsTile(
                  icon: Icons.language,
                  title: "Bahasa",
                  iconColor: Colors.indigo,
                  trailing: Text(
                    "ID",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  // onTap menggunakan fungsi default
                ),

                // -----------------------------------
                // KATEGORI 4: INFORMASI & BANTUAN
                // -----------------------------------
                _buildCategoryHeader("Informasi & Bantuan"),

                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: "Pusat Bantuan",
                  iconColor: Colors.yellow[800],
                ),

                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: "Kebijakan & Ketentuan",
                  iconColor: Colors.teal,
                ),

                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: "Tentang Aplikasi",
                  iconColor: Colors.grey,
                  trailing: Text(
                    "v1.0.0",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // -----------------------------------
                // KATEGORI 5: KELUAR
                // -----------------------------------
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: "Keluar Aplikasi",
                  iconColor: Colors.red,
                  isLogout: true,
                  onTap: () {
                    AuthService().logout();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
