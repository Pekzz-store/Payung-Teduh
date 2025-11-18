import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi Top Up Sederhana
  Future<void> topUpBalance({required String userId, required int amount}) async {
    try {
      // Update saldo user dengan cara INCREMENT (Penambahan otomatis di server)
      // Ini lebih aman daripada ambil data dulu baru ditambah di aplikasi
      await _db.collection('users').doc(userId).update({
        'balance': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception("Gagal Top Up: $e");
    }
  }
}