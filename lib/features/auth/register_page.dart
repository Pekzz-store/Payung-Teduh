import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk efek Blur (Glassmorphism)
import 'dart:math'; // Diperlukan untuk Random (Hujan)
import '../../services/auth_service.dart';

// Pastikan Class RainDrop dan RainPainter ada di project kamu.
// Jika kamu memisahkan file, import file tersebut.
// Jika tidak, saya sertakan class-nya di bagian bawah file ini agar tidak error.

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegisterPage({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // --- CONTROLLERS ---
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Fitur lihat password

  // --- LOGIKA REGISTER ---
  void _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        username: _nameController.text.trim(),
      );
      // Sign out setelah registrasi sukses agar tidak langsung ke home
      await AuthService().logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
        // Switch ke login page
        widget.onSwitchToLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA ANIMASI HUJAN (SAMA DENGAN LOGIN) ---
  late AnimationController _rainController;
  final List<RainDrop> _rainDrops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _rainController.addListener(() {
      setState(() {
        // Hapus tetesan yang lewat layar
        _rainDrops.removeWhere(
          (drop) => drop.positionY > MediaQuery.of(context).size.height,
        );

        // Tambah tetesan baru
        if (_rainDrops.length < 100) {
          _rainDrops.add(
            RainDrop(
              startX: _random.nextDouble() * MediaQuery.of(context).size.width,
              startY:
                  _random.nextDouble() *
                  MediaQuery.of(context).size.height /
                  2, // Mulai dari tengah ke atas
              speed: 2 + _random.nextDouble() * 2,
              length: 10 + _random.nextDouble() * 10,
            ),
          );
        }

        // Gerakkan tetesan
        for (var drop in _rainDrops) drop.positionY += drop.speed;
      });
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Agar background tidak terdorong keyboard
      body: Stack(
        children: [
          // 1. BACKGROUND GRADASI (SAMA PERSIS DENGAN LOGIN)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5), // Biru Terang
                  Color(0xFF1565C0), // Biru Sedang
                  Color(0xFF0D47A1), // Biru Gelap
                ],
              ),
            ),
          ),

          // 2. ANIMASI HUJAN
          AnimatedBuilder(
            animation: _rainController,
            builder: (context, child) {
              return CustomPaint(
                painter: RainPainter(_rainDrops),
                child: Container(),
              );
            },
          ),

          // 3. KONTEN (FORMULIR)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- HEADER ---
                  const Icon(
                    Icons.app_registration, // Ikon Register
                    size: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bergabunglah bersama RainGuard",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // --- FORM GLASSMORPHISM ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ), // Efek Blur Kaca
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Transparan
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            // INPUT NAMA
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white70,
                                ),
                                labelText: "Nama Lengkap",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // INPUT EMAIL
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white70,
                                ),
                                labelText: "Email",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // INPUT PASSWORD
                            TextField(
                              controller: _passController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                                labelText: "Password",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // TOMBOL DAFTAR
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white, // Tombol Putih
                                        foregroundColor: const Color(
                                          0xFF0D47A1,
                                        ), // Teks Biru Gelap
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: const Text(
                                        "DAFTAR SEKARANG",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- FOOTER (GANTI KE LOGIN) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: widget.onSwitchToLogin,
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Padding bawah tambahan
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASS HUJAN ---
// (Biarkan kode ini ada di sini jika class RainDrop/RainPainter belum ada di file terpisah)
// Jika sudah ada di file lain/global, bagian ini bisa dihapus.

class RainDrop {
  double startX;
  double startY;
  double positionY;
  double speed;
  double length;

  RainDrop({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.length,
  }) : positionY = startY;
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;

  RainPainter(this.rainDrops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in rainDrops) {
      canvas.drawLine(
        Offset(drop.startX, drop.positionY),
        Offset(drop.startX, drop.positionY + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}
