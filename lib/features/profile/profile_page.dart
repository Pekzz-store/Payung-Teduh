import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
// Import Service Tema
import '../../services/theme_service.dart';

// Pastikan file-file ini sudah ada di project kamu (sesuai langkah sebelumnya)
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ==========================================================
  // BAGIAN 1: FUNGSI-FUNGSI LOGIKA (DIALOG & BOTTOM SHEET)
  // ==========================================================

  // --- A. METODE PEMBAYARAN (BottomSheet) ---
  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pilih Metode Pembayaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Pilihan 1: Dompet (Default)
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text("RainGuard Wallet (Utama)"),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            
            // Pilihan 2: QRIS
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.black),
              title: const Text("QRIS"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Metode QRIS dipilih")),
                );
              },
            ),
            const Divider(),
            
            // Pilihan 3: Kartu
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.orange),
              title: const Text("Kartu Debit/Kredit"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur tambah kartu segera hadir!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- B. PENGATURAN NOTIFIKASI (Dialog dengan Switch) ---
  void _showNotificationSettings(BuildContext context) {
    // Variabel lokal dummy untuk tampilan (tidak disimpan permanen)
    bool notifHujan = true;
    bool notifSewa = true;
    bool notifPromo = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Pengaturan Notifikasi"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Peringatan Hujan"),
                  subtitle: const Text("Info cuaca real-time"),
                  value: notifHujan,
                  onChanged: (val) => setState(() => notifHujan = val),
                ),
                SwitchListTile(
                  title: const Text("Status Sewa"),
                  subtitle: const Text("Pengingat waktu & biaya"),
                  value: notifSewa,
                  onChanged: (val) => setState(() => notifSewa = val),
                ),
                SwitchListTile(
                  title: const Text("Info Promo"),
                  subtitle: const Text("Diskon dan penawaran"),
                  value: notifPromo,
                  onChanged: (val) => setState(() => notifPromo = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- C. PUSAT BANTUAN ---
  void _showHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Colors.blue),
            SizedBox(width: 10),
            Text("Pusat Bantuan"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Butuh bantuan? Hubungi tim support kami:"),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text("Email"),
              subtitle: const Text("support@rainguard.com"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("WhatsApp Priyo"),
              subtitle: const Text("+62 857-0748-0045"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // --- D. KEBIJAKAN & KETENTUAN ---
  void _showPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Kebijakan & Ketentuan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "1. PENGGUNAAN APLIKASI\n"
                  "Pengguna wajib menjaga kerahasiaan akun dan tidak meminjamkan akun kepada pihak lain.\n\n"
                  "2. PENYEWAAN PAYUNG\n"
                  "Payung harus dikembalikan dalam kondisi baik ke stasiun yang tersedia. Waktu sewa dihitung per jam.\n\n"
                  "3. PEMBAYARAN\n"
                  "Pembayaran dilakukan otomatis memotong saldo dompet aplikasi setelah payung dikembalikan.\n\n"
                  "4. DENDA & KERUSAKAN\n"
                  "Keterlambatan pengembalian lebih dari 24 jam atau kerusakan fisik pada payung akan dikenakan denda sesuai ketentuan yang berlaku.",
                  style: TextStyle(height: 1.5, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- E. TENTANG APLIKASI ---
  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "RainGuard",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2025 RainGuard Inc.",
      applicationIcon: const Icon(Icons.beach_access, size: 50, color: Colors.blueAccent),
      children: [
        const SizedBox(height: 20),
        const Text(
          "RainGuard adalah aplikasi penyewaan payung pintar yang membantu Anda tetap kering saat hujan tak terduga. Sedia payung sebelum hujan, sekarang lebih mudah!",
        ),
      ],
    );
  }

  // ==========================================================
  // BAGIAN 2: TAMPILAN UTAMA (BUILD)
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Jika user belum login, tampilkan widget kosong
    if (user == null) return const SizedBox();

    // Cek apakah tema yang sedang aktif adalah Dark Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Helper Widget untuk membuat item list dengan cepat
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
            title: Text(title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87)),
            secondary: Icon(icon, color: iconColor ?? (isDarkMode ? Colors.white70 : Colors.grey[800])),
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
          leading: Icon(icon, color: iconColor ?? (isDarkMode ? Colors.white70 : Colors.grey[800])),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red : (isDarkMode ? Colors.white : Colors.black87),
              fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: trailing ?? (isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 18)),
          onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigasi ke $title')));
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: true),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // --- Avatar & Info User (Tidak Diubah) ---
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blue[100],
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 40, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- 1. PENGATURAN AKUN ---
                _buildCategoryHeader("Pengaturan Akun"),

                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: "Edit Profil",
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage(currentName: name)),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: "Ganti Kata Sandi",
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                    );
                  },
                ),

                // --- 2. TRANSAKSI & PREFERENSI ---
                _buildCategoryHeader("Transaksi & Preferensi"),
                
                // Metode Pembayaran (Interaktif)
                _buildSettingsTile(
                  icon: Icons.credit_card,
                  title: "Metode Pembayaran",
                  iconColor: Colors.green,
                  onTap: () => _showPaymentMethods(context),
                ),
                
                // Pengaturan Notifikasi (Interaktif)
                _buildSettingsTile(
                  icon: Icons.notifications_none,
                  title: "Pengaturan Notifikasi",
                  iconColor: Colors.redAccent,
                  onTap: () => _showNotificationSettings(context),
                ),

                // --- 3. TAMPILAN & BAHASA ---
                _buildCategoryHeader("Tampilan & Bahasa"),

                // Mode Gelap (Menggunakan SwitchListTile)
                _buildSettingsTile(
                  icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  title: "Mode Gelap",
                  iconColor: Colors.purple,
                  isSwitch: true,
                  switchValue: isDarkMode,
                  onSwitchChanged: (val) => ThemeService.toggleTheme(val),
                ),

                _buildSettingsTile(
                  icon: Icons.language,
                  title: "Bahasa",
                  iconColor: Colors.indigo,
                  trailing: Text("ID", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey)),
                ),

                // --- 4. INFORMASI & BANTUAN ---
                _buildCategoryHeader("Informasi & Bantuan"),

                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: "Pusat Bantuan",
                  iconColor: Colors.yellow[800],
                  onTap: () => _showHelpCenter(context),
                ),

                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: "Kebijakan & Ketentuan",
                  iconColor: Colors.teal,
                  onTap: () => _showPolicy(context),
                ),

                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: "Tentang Aplikasi",
                  iconColor: Colors.grey,
                  trailing: Text("v1.0.0", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey)),
                  onTap: () => _showAboutApp(context),
                ),

                const SizedBox(height: 25),

                // --- 5. LOGOUT ---
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: "Keluar Aplikasi",
                  iconColor: Colors.red,
                  isLogout: true,
                  onTap: () => AuthService().logout(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
