import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/data_seeder.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isSeeding = false;

  // Tambah stasiun baru ke koleksi 'stations'
  Future<void> _addStation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required int total,
    required int available,
  }) async {
    await _db.collection('stations').add({
      'name': name,
      'address': address,
      'geo_point': GeoPoint(latitude, longitude),
      'total_umbrellas': total,
      'available_umbrellas': available,
      'price_per_hour': 5000,
      'is_active': true,
    });
  }

  Future<void> _deleteStation(String docId) async {
    await _db.collection('stations').doc(docId).delete();
  }

  // Ubah stok dengan transaksi untuk mencegah race condition.
  Future<void> _changeStock(String docId, int delta) async {
    final docRef = _db.collection('stations').doc(docId);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception('Station not found');
      final data = snapshot.data() as Map<String, dynamic>;
      final int current = (data['available_umbrellas'] ?? 0) as int;
      final int total = (data['total_umbrellas'] ?? current) as int;
      int next = current + delta;
      if (next < 0) next = 0;
      if (next > total) next = total;
      tx.update(docRef, {'available_umbrellas': next});
    });
  }

  // Tampilkan dialog untuk menambah stasiun baru
  void _showAddStationDialog() {
    final _nameC = TextEditingController();
    final _addrC = TextEditingController();
    final _latC = TextEditingController();
    final _lngC = TextEditingController();
    final _totalC = TextEditingController(text: '10');
    final _availC = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Stasiun'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: _addrC,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: _latC,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              TextField(
                controller: _lngC,
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
              TextField(
                controller: _totalC,
                decoration: const InputDecoration(labelText: 'Total Payung'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _availC,
                decoration: const InputDecoration(labelText: 'Stok Tersedia'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameC.text.trim();
              final addr = _addrC.text.trim();
              final lat = double.tryParse(_latC.text.trim());
              final lng = double.tryParse(_lngC.text.trim());
              final total = int.tryParse(_totalC.text.trim()) ?? 0;
              final avail = int.tryParse(_availC.text.trim()) ?? 0;
              if (name.isEmpty || addr.isEmpty || lat == null || lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon isi semua field lokasi dengan benar'),
                  ),
                );
                return;
              }
              try {
                await _addStation(
                  name: name,
                  address: addr,
                  latitude: lat,
                  longitude: lng,
                  total: total,
                  available: avail,
                );
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal tambah stasiun: $e')),
                  );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedData() async {
    if (!kDebugMode) return; // Hanya aktif di mode debug
    setState(() => _isSeeding = true);
    try {
      await DataSeeder().seedStations();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seeder selesai: data stasiun terkirim.'),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Seeder gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Yakin ingin logout dari akun admin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await AuthService().logout();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang, Admin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Akses cepat:'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isSeeding ? null : _seedData,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isSeeding ? 'Seeding...' : 'Seed sample stations (debug)',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('stations').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final int available =
                          (data['available_umbrellas'] ?? 0) as int;
                      final int total = (data['total_umbrellas'] ?? 0) as int;
                      return ListTile(
                        title: Text(data['name'] ?? 'Unnamed'),
                        subtitle: Text(data['address'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease stock
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.orange,
                              ),
                              onPressed: () async {
                                try {
                                  await _changeStock(doc.id, -1);
                                } catch (e) {
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal ubah stok: $e'),
                                      ),
                                    );
                                }
                              },
                            ),
                            Text(
                              '$available / $total',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Increase stock
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                try {
                                  await _changeStock(doc.id, 1);
                                } catch (e) {
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal ubah stok: $e'),
                                      ),
                                    );
                                }
                              },
                            ),
                            // Edit
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => _showEditStationDialog(doc),
                            ),
                            // Delete
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Hapus Stasiun'),
                                    content: const Text(
                                      'Yakin ingin menghapus stasiun ini?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  try {
                                    await _deleteStation(doc.id);
                                  } catch (e) {
                                    if (mounted)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal hapus: $e'),
                                        ),
                                      );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStationDialog,
        child: const Icon(Icons.add_location_alt),
        tooltip: 'Tambah Stasiun',
      ),
    );
  }

  // Dialog untuk mengedit stasiun
  void _showEditStationDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final GeoPoint geo = (data['geo_point'] is GeoPoint)
        ? data['geo_point'] as GeoPoint
        : GeoPoint(0, 0);
    final _nameC = TextEditingController(text: data['name'] ?? '');
    final _addrC = TextEditingController(text: data['address'] ?? '');
    final _latC = TextEditingController(text: geo.latitude.toString());
    final _lngC = TextEditingController(text: geo.longitude.toString());
    final _totalC = TextEditingController(
      text: (data['total_umbrellas'] ?? 0).toString(),
    );
    final _availC = TextEditingController(
      text: (data['available_umbrellas'] ?? 0).toString(),
    );
    final _priceC = TextEditingController(
      text: (data['price_per_hour'] ?? 5000).toString(),
    );
    bool _isActive = data['is_active'] ?? true;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Stasiun'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameC,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: _addrC,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                  ),
                  TextField(
                    controller: _latC,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                  TextField(
                    controller: _lngC,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                  TextField(
                    controller: _totalC,
                    decoration: const InputDecoration(
                      labelText: 'Total Payung',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _availC,
                    decoration: const InputDecoration(
                      labelText: 'Stok Tersedia',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _priceC,
                    decoration: const InputDecoration(labelText: 'Harga / jam'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      const Text('Aktif'),
                      Checkbox(
                        value: _isActive,
                        onChanged: (v) {
                          setStateDialog(() => _isActive = v ?? true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameC.text.trim();
                  final addr = _addrC.text.trim();
                  final lat = double.tryParse(_latC.text.trim());
                  final lng = double.tryParse(_lngC.text.trim());
                  final total = int.tryParse(_totalC.text.trim()) ?? 0;
                  final avail = int.tryParse(_availC.text.trim()) ?? 0;
                  final price = int.tryParse(_priceC.text.trim()) ?? 5000;
                  if (name.isEmpty ||
                      addr.isEmpty ||
                      lat == null ||
                      lng == null) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mohon isi field nama, alamat, dan koordinat dengan benar',
                          ),
                        ),
                      );
                    return;
                  }
                  try {
                    await _db.collection('stations').doc(doc.id).update({
                      'name': name,
                      'address': addr,
                      'geo_point': GeoPoint(lat, lng),
                      'total_umbrellas': total,
                      'available_umbrellas': avail,
                      'price_per_hour': price,
                      'is_active': _isActive,
                    });
                    if (mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal update: $e')),
                      );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
