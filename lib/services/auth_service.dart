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
        'balance': 50000, // Bonus awal
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // FITUR BARU: UPDATE PROFILE & GANTI PASSWORD
  // ============================================================

  // --- 1. UPDATE USERNAME ---
  Future<void> updateUsername(String newName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update di Firestore
      await _db.collection('users').doc(user.uid).update({
        'username': newName,
      });
      // Update di Firebase Auth (agar sinkron)
      await user.updateDisplayName(newName); 
    }
  }

  // --- 2. GANTI PASSWORD ---
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      // Re-autentikasi user (Wajib untuk keamanan Firebase sebelum ganti pass)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        throw Exception("Password lama salah atau terjadi kesalahan sistem.");
      }
    }
  }
}