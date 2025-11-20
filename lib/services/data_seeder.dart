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

    // --- DATA DUMMY 1: Matahari ---
    String id1 = stationsRef.doc().id; // Bikin ID unik otomatis
    batch.set(stationsRef.doc(id1), {
      'name': 'Matahari Madiun',
      'address': 'Matahari Departemen Store',
      // GeoPoint(Latitude, Longitude) -> Koordinat Jakarta
      'geo_point': const GeoPoint(-7.625600, 111.519953),
      'total_umbrellas': 10,
      'available_umbrellas': 8,
      'price_per_hour': 5000,
      'is_active': true,
    });

    // --- DATA DUMMY 2: Sun City ---
    String id2 = stationsRef.doc().id;
    batch.set(stationsRef.doc(id2), {
      'name': 'Sun City Madiun',
      'address': 'Sun City Department Store',
      'geo_point': const GeoPoint(-7.622488, 111.536352),
      'total_umbrellas': 15,
      'available_umbrellas': 2,
      'price_per_hour': 5000,
      'is_active': true,
    });

    // --- DATA DUMMY 3: Alun-Alun ---
    String id3 = stationsRef.doc().id;
    batch.set(stationsRef.doc(id3), {
      'name': 'Alun-Alun Madiun',
      'address': 'Alun-Alun Kota Madiun',
      'geo_point': const GeoPoint(-7.629182, 111.516879),
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
