import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  // Ini akses ke database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi ini yang nanti kita panggil lewat tombol
  Future<void> seedStations() async {
    // Kita pakai 'Batch'. Ini cara pro: kirim banyak data dalam 1 paket.
    // Kalau satu gagal, semua batal. Jadi database tetap bersih.
    WriteBatch batch = _db.batch();

    // Kita mau isi ke folder (collection) bernama 'stations'
    CollectionReference stationsRef = _db.collection('stations');

    print("🚀 Mulai mengirim data...");

    // --- DATA DUMMY 1: Stasiun MRT ---
    String id1 = stationsRef.doc().id; // Bikin ID unik otomatis
    batch.set(stationsRef.doc(id1), {
      'name': 'Stasiun MRT Bundaran HI',
      'address': 'Jl. M.H. Thamrin No.1',
      // GeoPoint(Latitude, Longitude) -> Koordinat Jakarta
      'geo_point': const GeoPoint(-6.193046, 106.822331), 
      'total_umbrellas': 10,
      'available_umbrellas': 8,
      'price_per_hour': 5000,
      'is_active': true,
    });

    // --- DATA DUMMY 2: Grand Indonesia ---
    String id2 = stationsRef.doc().id;
    batch.set(stationsRef.doc(id2), {
      'name': 'Grand Indonesia - West Mall',
      'address': 'Lobby Arjuna',
      'geo_point': const GeoPoint(-6.194177, 106.819737),
      'total_umbrellas': 15,
      'available_umbrellas': 2, 
      'price_per_hour': 5000,
      'is_active': true,
    });

    // --- DATA DUMMY 3: Halte Tosari ---
    String id3 = stationsRef.doc().id;
    batch.set(stationsRef.doc(id3), {
      'name': 'Halte Transjakarta Tosari',
      'address': 'Jl. Jend. Sudirman',
      'geo_point': const GeoPoint(-6.199323, 106.823774),
      'total_umbrellas': 5,
      'available_umbrellas': 5, 
      'price_per_hour': 5000,
      'is_active': true,
    });

    // Kirim paketnya sekarang!
    await batch.commit();
    print("✅ SUKSES! Data sudah masuk Firebase.");
  }
}