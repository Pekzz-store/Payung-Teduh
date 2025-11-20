import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk efek blur (kaca)
import 'dart:math'; // Untuk Random()
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  const LoginPage({super.key, required this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Tambahkan 'TickerProviderStateMixin' untuk animasi hujan
class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // --- LOGIKA ASLI (TIDAK DIUBAH SAMA SEKALI) ---
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().login(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // -----------------------------------------------

  // --- LOGIKA BARU UNTUK ANIMASI HUJAN ---
  late AnimationController _rainController;
  final List<RainDrop> _rainDrops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi hujan
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animasi pergerakan cepat
    )..repeat(); // Ulangi terus

    // Listener untuk memperbarui posisi tetesan hujan
    _rainController.addListener(() {
      setState(() {
        // Hapus tetesan yang sudah melewati layar
        _rainDrops.removeWhere(
          (drop) => drop.positionY > MediaQuery.of(context).size.height,
        );

        // Tambah tetesan baru jika kurang dari batas
        if (_rainDrops.length < 100) {
          // Jumlah tetesan hujan
          _rainDrops.add(
            RainDrop(
              startX: _random.nextDouble() * MediaQuery.of(context).size.width,
              startY:
                  _random.nextDouble() *
                  MediaQuery.of(context).size.height /
                  2, // Mulai dari atas layar
              speed: 2 + _random.nextDouble() * 2, // Kecepatan acak
              length: 10 + _random.nextDouble() * 10, // Panjang tetesan acak
            ),
          );
        }

        // Perbarui posisi tetesan yang ada
        for (var drop in _rainDrops) {
          drop.positionY += drop.speed;
        }
      });
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. BACKGROUND GRADASI PREMIUM
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E88E5), // Biru
                  Color(0xFF1565C0), // Biru Gelap
                  Color(0xFF0D47A1), // Biru Sangat Gelap
                ],
              ),
            ),
          ),

          // 2. EFEK HUJAN (Di atas background, di bawah konten login)
          AnimatedBuilder(
            animation: _rainController,
            builder: (context, child) {
              return CustomPaint(
                painter: RainPainter(_rainDrops),
                child:
                    Container(), // CustomPaint harus punya child (bisa kosong)
              );
            },
          ),

          // 3. KONTEN UTAMA (FORM LOGIN)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO & HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.beach_access,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Silakan masuk ke akun Anda",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // 4. FORM LOGIN (EFEK KACA / GLASSMORPHISM)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ), // Efek Blur
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.1,
                          ), // Transparan putih
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Input Email
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
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

                            // Input Password
                            TextField(
                              controller: _passController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
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

                            // Tombol Masuk
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .white, // Tombol Putih Kontras
                                        foregroundColor:
                                            Colors.blue[900], // Teks Biru
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
                                        "MASUK",
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

                  // Footer (Daftar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: widget.onSwitchToRegister,
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASS BARU UNTUK REPRESENTASI TETESAN HUJAN ---
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

// --- CLASS BARU UNTUK MENGGAMBAR HUJAN ---
class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;

  RainPainter(this.rainDrops);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.6) // Warna tetesan
      ..strokeWidth =
          1.5 // Ketebalan tetesan
      ..strokeCap = StrokeCap.round; // Ujung tetesan bulat

    for (var drop in rainDrops) {
      canvas.drawLine(
        Offset(drop.startX, drop.positionY),
        Offset(drop.startX, drop.positionY + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) {
    return true; // Selalu repaint agar animasi berjalan
  }
}
