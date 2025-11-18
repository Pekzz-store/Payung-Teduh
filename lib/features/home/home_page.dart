import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Peta
import 'package:latlong2/latlong.dart'; // Koordinat
import 'package:cloud_firestore/cloud_firestore.dart'; // Database
import 'package:firebase_auth/firebase_auth.dart'; // Auth
import 'package:geolocator/geolocator.dart'; // GPS

// --- IMPORT FILES ---
import '../../models/station_model.dart';
import '../../services/rental_service.dart';
import 'widgets/active_rental_card.dart';
import 'widgets/top_up_sheet.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller untuk menggerakkan Peta
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  // Data Stasiun (Untuk Search)
  List<StationModel> _allStations = [];
  List<StationModel> _filteredStations = [];
  bool _isSearching = false;

  // Lokasi User (Default: Jakarta)
  LatLng _myLocation = const LatLng(-6.194177, 106.822331); 

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Cek GPS saat aplikasi dibuka
  }

  // Fungsi Cek GPS
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah GPS nyala?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // 2. Cek Izin Aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 3. Ambil Lokasi
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _myLocation = LatLng(position.latitude, position.longitude);
    });

    // 4. Pindahkan kamera peta ke lokasi user
    _mapController.move(_myLocation, 15);
  }

  // Fungsi Search
  void _runFilter(String keyword) {
    List<StationModel> results = [];
    if (keyword.isEmpty) {
      results = _allStations;
    } else {
      results = _allStations
          .where((station) => station.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredStations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final String currentUserId = user.uid;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ==============================================================
          // LAYER 1: PETA
          // ==============================================================
          FlutterMap(
            mapController: _mapController, // Pasang Controller
            options: MapOptions(
              initialCenter: _myLocation,
              initialZoom: 15.0,
              onTap: (_, __) {
                // Tutup keyboard/search jika klik peta
                FocusScope.of(context).unfocus();
                setState(() => _isSearching = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rainguard.app',
              ),
              
              // Marker Lokasi Saya (Titik Biru Berdenyut)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _myLocation,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)]
                      ),
                    ),
                  ),
                ],
              ),

              // Marker Stasiun dari Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('stations').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  // Simpan data untuk fitur search
                  var docs = snapshot.data!.docs;
                  // Kita update list stasiun lokal jika data baru masuk dan user TIDAK sedang mengetik
                  if (!_isSearching && _searchController.text.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                       if (mounted) {
                         _allStations = docs.map((d) => StationModel.fromFirestore(d)).toList();
                       }
                    });
                  }

                  List<Marker> markers = docs.map((doc) {
                    StationModel station = StationModel.fromFirestore(doc);
                    return Marker(
                      point: LatLng(station.latitude, station.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => _showStationDetail(context, station, currentUserId),
                        child: _buildCustomMarker(station),
                      ),
                    );
                  }).toList();

                  return MarkerLayer(markers: markers);
                },
              ),
            ],
          ),

          // ==============================================================
          // LAYER 2: SEARCH BAR CANGGIH
          // ==============================================================
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // KOTAK PENCARIAN
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    controller: _searchController,
                    onTap: () => setState(() => _isSearching = true),
                    onChanged: (value) {
                       setState(() => _isSearching = true);
                       _runFilter(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Cari lokasi payung...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      suffixIcon: _isSearching 
                        ? IconButton(
                            icon: const Icon(Icons.close), 
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                              setState(() => _isSearching = false);
                            }
                          ) 
                        : null,
                    ),
                  ),
                ),

                // HASIL PENCARIAN (Muncul jika sedang mencari)
                if (_isSearching && _filteredStations.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
                    ),
                    constraints: const BoxConstraints(maxHeight: 200), // Batas tinggi list
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = _filteredStations[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.blue),
                          title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(station.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            // 1. Pindahkan Peta ke lokasi stasiun
                            _mapController.move(LatLng(station.latitude, station.longitude), 18);
                            // 2. Tutup Search
                            setState(() => _isSearching = false);
                            FocusScope.of(context).unfocus();
                            // 3. Buka Detail
                            _showStationDetail(context, station, currentUserId);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ==============================================================
          // LAYER 3: UI STATUS AKTIF SEWA (Jika ada)
          // ==============================================================
          // Kita taruh di bawah agar tidak tertutup search list
           Positioned(
            top: 120, // Geser ke bawah sedikit
            left: 0,
            right: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rentals')
                  .where('userId', isEqualTo: currentUserId)
                  .where('status', isEqualTo: 'active')
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  var rentalDoc = snapshot.data!.docs.first;
                  return ActiveRentalCard(
                    rentalData: rentalDoc.data() as Map<String, dynamic>,
                    rentalId: rentalDoc.id,
                  );
                } 
                return const SizedBox();
              },
            ),
          ),

          // ==============================================================
          // LAYER 4: TOMBOL GPS (KANAN TENGAH)
          // ==============================================================
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: "gps_btn",
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
              onPressed: () => _determinePosition(), // Panggil fungsi GPS
            ),
          ),

          // ==============================================================
          // LAYER 5: SALDO & TOP UP
          // ==============================================================
          Positioned(
            bottom: 30,
            left: 20,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
              builder: (context, snapshot) {
                int balance = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                   var data = snapshot.data!.data() as Map<String, dynamic>?;
                   balance = data?['balance'] ?? 0;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Saldo Anda", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text("Rp $balance", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TopUpSheet(userId: currentUserId),
                        ),
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                          child: const Icon(Icons.add, size: 18, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER (Sama seperti sebelumnya) ---
  Widget _buildCustomMarker(StationModel station) {
    bool isAvailable = station.availableUmbrellas > 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.blueAccent : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: const Icon(Icons.beach_access, color: Colors.white, size: 24),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]
          ),
          child: Text(
            "${station.availableUmbrellas} unit",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? Colors.black : Colors.red),
          ),
        )
      ],
    );
  }

  void _showStationDetail(BuildContext context, StationModel station, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(24),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, color: Colors.grey[300])),
              const SizedBox(height: 24),
              Text(station.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(station.address, style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Stok Payung", style: TextStyle(color: Colors.grey)),
                      Text("${station.availableUmbrellas} Unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tarif", style: TextStyle(color: Colors.grey)),
                      Text("Rp 5.000/jam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: station.availableUmbrellas > 0 
                    ? () {
                        Navigator.pop(context);
                        _showRentalConfirmation(context, station, userId); 
                      }
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(station.availableUmbrellas > 0 ? "SEWA SEKARANG" : "STOK HABIS"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRentalConfirmation(BuildContext context, StationModel station, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Sewa"),
        content: Text("Sewa payung di ${station.name}?\n(Minimal saldo Rp 5.000)"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔄 Memproses..."), duration: Duration(seconds: 1)));
              try {
                await RentalService().startRental(stationId: station.id, stationName: station.name, userId: userId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Sewa Berhasil!"), backgroundColor: Colors.green));
              } catch (e) {
                String msg = e.toString().replaceAll("Exception: ", "");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $msg"), backgroundColor: Colors.red));
              }
            },
            child: const Text("KONFIRMASI"),
          )
        ],
      ),
    );
  }
}