import 'package:cloud_firestore/cloud_firestore.dart';

class StationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableUmbrellas;

  StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableUmbrellas,
  });

  // Factory: Cara pro mengubah data mentah Firebase (JSON) menjadi Object Dart
  factory StationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Mengambil GeoPoint (format lokasi Firebase)
    GeoPoint geo = data['geo_point'];

    return StationModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: geo.latitude,
      longitude: geo.longitude,
      availableUmbrellas: data['available_umbrellas'] ?? 0,
    );
  }
}