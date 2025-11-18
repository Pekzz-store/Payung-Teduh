import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan User yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // Stream untuk memantau status login (Real-time)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- LOGIN ---
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // --- REGISTER ---
  Future<void> register({
    required String email, 
    required String password, 
    required String username
  }) async {
    // 1. Buat Akun di Firebase Auth (Email & Password)
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    // 2. Buat Data Diri & DOMPET di Firestore Database
    // Ini PENTING agar fitur saldo jalan
    if (cred.user != null) {
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'username': username,
        'email': email,
        'balance': 50000, // BONUS DAFTAR BARU: Rp 50.000
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }
}