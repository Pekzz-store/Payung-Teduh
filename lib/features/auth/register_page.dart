import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin; // Untuk pindah ke halaman Login
  const RegisterPage({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        username: _nameController.text.trim(),
      );
      // Jika sukses, tidak perlu navigasi manual. 
      // Splash Screen akan mendeteksi perubahan status login otomatis.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.app_registration, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text("Buat Akun RainGuard", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
                const SizedBox(height: 24),
                
                _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text("DAFTAR SEKARANG"),
                    ),
                
                TextButton(
                  onPressed: widget.onSwitchToLogin, 
                  child: const Text("Sudah punya akun? Login di sini")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}