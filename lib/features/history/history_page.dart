import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import halaman detail agar bisa diklik
import 'history_detail_page.dart'; 

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Perjalanan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50], // Background sedikit abu agar kartu menonjol
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rentals')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed') // Filter: Hanya yang sudah selesai
            .snapshots(),
        builder: (context, snapshot) {
          // 1. State Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. State Kosong
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("Belum ada riwayat sewa", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;
          
          // 3. Sorting Manual (Terbaru di Atas)
          // Karena Query Firestore majemuk butuh Index, kita sort di klien saja biar cepat
          docs.sort((a, b) {
             Timestamp t1 = a['startTime'];
             Timestamp t2 = b['startTime'];
             return t2.compareTo(t1);
          });

          // 4. List View
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (c, i) => const SizedBox(height: 15), // Jarak antar kartu
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              
              // Bungkus dengan GestureDetector agar bisa diklik
              return GestureDetector(
                onTap: () {
                  // Navigasi ke Halaman Detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryDetailPage(data: data),
                    ),
                  );
                },
                child: _buildHistoryCard(data),
              );
            },
          );
        },
      ),
    );
  }

  // Widget Kartu Riwayat
  Widget _buildHistoryCard(Map<String, dynamic> data) {
    Timestamp startTs = data['startTime'];
    Timestamp? endTs = data['endTime'];
    int cost = data['totalCost'] ?? 0;
    String stationName = data['stationName'] ?? 'Lokasi Tidak Diketahui';

    // Format Tanggal (Contoh: 18 Nov 2025, 14:30)
    String dateStr = DateFormat('dd MMM yyyy, HH:mm').format(startTs.toDate());
    
    // Hitung Durasi Tampilan
    String durationStr = "-";
    if (endTs != null) {
      int minutes = endTs.toDate().difference(startTs.toDate()).inMinutes;
      if (minutes < 60) {
        durationStr = "$minutes Menit";
      } else {
        int hours = (minutes / 60).floor();
        int mins = minutes % 60;
        durationStr = "$hours Jam $mins Menit";
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          // Ikon status (Centang Biru)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          
          // Info Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text("Durasi: $durationStr", style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          // Info Harga (Kanan)
          Text("-Rp $cost", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}