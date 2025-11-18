import 'package:cloud_firestore/cloud_firestore.dart';

class RentalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. MEMULAI SEWA (START) ---
  Future<void> startRental({
    required String stationId,
    required String stationName,
    required String userId,
  }) async {
    return _db.runTransaction((transaction) async {
      // Referensi Dokumen
      DocumentReference stationRef = _db.collection('stations').doc(stationId);
      DocumentReference userRef = _db.collection('users').doc(userId);

      // Baca Data Terbaru (Snapshot)
      DocumentSnapshot stationSnapshot = await transaction.get(stationRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      // A. Validasi Stok
      if (!stationSnapshot.exists) throw Exception("Stasiun tidak valid!");
      int currentStock = stationSnapshot.get('available_umbrellas');
      if (currentStock <= 0) throw Exception("Stok payung habis!");

      // B. Validasi Saldo (Minimal Rp 5.000 untuk jaminan 1 jam pertama)
      if (!userSnapshot.exists) throw Exception("User tidak valid!");
      int currentBalance = userSnapshot.get('balance');
      if (currentBalance < 5000) {
        throw Exception("Saldo tidak cukup! Minimal Rp 5.000");
      }

      // C. Eksekusi: Kurangi Stok
      transaction.update(stationRef, {
        'available_umbrellas': currentStock - 1,
      });

      // D. Eksekusi: Buat Tiket Sewa Baru
      DocumentReference newRentalRef = _db.collection('rentals').doc();
      transaction.set(newRentalRef, {
        'rentalId': newRentalRef.id,
        'userId': userId,
        'stationId': stationId,
        'stationName': stationName,
        'startTime': FieldValue.serverTimestamp(), // Waktu mulai (Server Time)
        'status': 'active', // Status sewa berjalan
        'totalCost': 0,
      });
    });
  }

  // --- 2. MENGEMBALIKAN PAYUNG (RETURN & HITUNG BIAYA) ---
  Future<void> returnRental({
    required String rentalId,
    required String stationId,
    required String userId,
  }) async {
    return _db.runTransaction((transaction) async {
      DocumentReference rentalRef = _db.collection('rentals').doc(rentalId);
      DocumentReference stationRef = _db.collection('stations').doc(stationId);
      DocumentReference userRef = _db.collection('users').doc(userId);

      // Baca Data
      DocumentSnapshot rentalSnapshot = await transaction.get(rentalRef);
      DocumentSnapshot stationSnapshot = await transaction.get(stationRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (!rentalSnapshot.exists) throw Exception("Data sewa tidak ditemukan");

      // A. HITUNG DURASI & BIAYA
      Timestamp startTs = rentalSnapshot.get('startTime');
      DateTime startTime = startTs.toDate();
      DateTime endTime = DateTime.now();
      
      // Hitung selisih waktu dalam menit
      int durationMinutes = endTime.difference(startTime).inMinutes;
      
      // Logika Tarif: Rp 5.000 per jam (Pembulatan ke atas)
      // Contoh: 1 jam 5 menit = Dihitung 2 jam
      int hoursBilled = (durationMinutes / 60).ceil();
      if (hoursBilled < 1) hoursBilled = 1; // Minimal bayar 1 jam
      
      int finalCost = hoursBilled * 5000; 

      // B. Update Status Sewa (Selesai)
      transaction.update(rentalRef, {
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
        'totalCost': finalCost,
        'durationMinutes': durationMinutes,
      });

      // C. Kembalikan Stok Payung (+1)
      if (stationSnapshot.exists) {
        int currentStock = stationSnapshot.get('available_umbrellas');
        transaction.update(stationRef, {
          'available_umbrellas': currentStock + 1,
        });
      }

      // D. Potong Saldo User
      if (userSnapshot.exists) {
        int currentBalance = userSnapshot.get('balance');
        transaction.update(userRef, {
          'balance': currentBalance - finalCost
        });
      }
    });
  }
}