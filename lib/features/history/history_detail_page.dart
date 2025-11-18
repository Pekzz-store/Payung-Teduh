import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> data; // Data transaksi yang dikirim dari list

  const HistoryDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Parsing Data
    Timestamp startTs = data['startTime'];
    Timestamp? endTs = data['endTime'];
    int cost = data['totalCost'] ?? 0;
    String stationName = data['stationName'] ?? 'Unknown';
    String rentalId = data['rentalId'] ?? '-';
    
    // Format Waktu
    String dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(startTs.toDate()); // Butuh locale ID jika ada
    String timeStart = DateFormat('HH:mm').format(startTs.toDate());
    String timeEnd = endTs != null ? DateFormat('HH:mm').format(endTs.toDate()) : "-";

    // Hitung Durasi Manual untuk Tampilan
    String durationStr = "-";
    if (endTs != null) {
      int minutes = endTs.toDate().difference(startTs.toDate()).inMinutes;
      durationStr = "$minutes Menit";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU UTAMA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  // Icon Sukses
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 15),
                  const Text("Pembayaran Berhasil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(dateStr, style: TextStyle(color: Colors.grey[600])),
                  
                  const Divider(height: 40),
                  
                  // Total Bayar Besar
                  Text("Rp $cost", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),
                  
                  const Divider(),
                  
                  // Detail Lokasi
                  _buildRow("Lokasi Sewa", stationName, isBold: true),
                  _buildRow("Waktu Mulai", timeStart),
                  _buildRow("Waktu Selesai", timeEnd),
                  _buildRow("Durasi Total", durationStr),
                  
                  const Divider(height: 30),
                  
                  _buildRow("ID Pesanan", "#${rentalId.substring(0, 8).toUpperCase()}", isSmall: true),
                  _buildRow("Metode Bayar", "RainGuard Wallet", isSmall: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TOMBOL BANTUAN
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hubungi CS: support@rainguard.com")));
                },
                icon: const Icon(Icons.help_outline),
                label: const Text("Laporkan Masalah"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: isSmall ? 12 : 14)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmall ? 12 : 14,
            color: Colors.black87
          )),
        ],
      ),
    );
  }
}