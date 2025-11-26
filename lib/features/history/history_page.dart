import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import halaman detail
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Semua'; // Filter: Semua, Minggu Ini, Bulan Ini

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    // 1. DETEKSI MODE GELAP
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Perjalanan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        // Hapus warna hardcoded, biarkan mengikuti tema dari main.dart
      ),
      // Hapus backgroundColor hardcoded, ganti dengan logika tema
      backgroundColor: isDarkMode ? null : Colors.grey[50], 
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rentals')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data?.docs ?? [];

          // Sorting Terbaru
          docs.sort((a, b) {
            Timestamp t1 = a['startTime'];
            Timestamp t2 = b['startTime'];
            return t2.compareTo(t1);
          });

          // Filter Logic
          List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
            if (_selectedFilter == 'Semua') return true;
            Timestamp ts = doc['startTime'];
            DateTime date = ts.toDate();
            DateTime now = DateTime.now();

            if (_selectedFilter == 'Minggu Ini') {
              return now.difference(date).inDays < 7;
            } else if (_selectedFilter == 'Bulan Ini') {
              return now.month == date.month && now.year == date.year;
            }
            return true;
          }).toList();

          // Hitung Total
          int totalExpense = filteredDocs.fold(0, (sum, doc) {
            return sum + (doc['totalCost'] as int? ?? 0);
          });

          return Column(
            children: [
              // Ringkasan Pengeluaran
              _buildSummaryCard(totalExpense, filteredDocs.length, isDarkMode),

              // Filter Chips
              _buildFilterChips(isDarkMode),

              // List Riwayat
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 80, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text("Tidak ada riwayat", style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          var data = filteredDocs[index].data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDetailPage(data: data),
                                ),
                              );
                            },
                            // Kirim status dark mode ke widget kartu
                            child: _buildHistoryCard(data, isDarkMode),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int total, int count, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Gradasi sedikit lebih gelap di mode malam agar tidak silau
          colors: isDark 
              ? [Colors.blue[900]!, Colors.blue[800]!] 
              : [Colors.blueAccent, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            "Rp ${NumberFormat('#,###').format(total)}",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text("$count Transaksi $_selectedFilter", style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    List<String> filters = ['Semua', 'Minggu Ini', 'Bulan Ini'];
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (c, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          String filter = filters[index];
          bool isSelected = _selectedFilter == filter;
          
          // Warna Chip menyesuaikan tema
          Color chipBg = isSelected 
              ? Colors.blueAccent 
              : (isDark ? Colors.grey[800]! : Colors.white);
          Color chipText = isSelected 
              ? Colors.white 
              : (isDark ? Colors.white70 : Colors.black87);

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() => _selectedFilter = filter);
            },
            selectedColor: Colors.blueAccent,
            labelStyle: TextStyle(color: chipText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data, bool isDark) {
    Timestamp startTs = data['startTime'];
    Timestamp? endTs = data['endTime'];
    int cost = data['totalCost'] ?? 0;
    String stationName = data['stationName'] ?? 'Lokasi Tidak Diketahui';
    String dateStr = DateFormat('dd MMM yyyy, HH:mm').format(startTs.toDate());

    String durationStr = "-";
    if (endTs != null) {
      int minutes = endTs.toDate().difference(startTs.toDate()).inMinutes;
      durationStr = minutes < 60 ? "$minutes Menit" : "${(minutes / 60).floor()} Jam ${minutes % 60} Menit";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // WARNA KARTU ADAPTIF
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        // Border menyesuaikan tema
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    // Warna teks otomatis putih di dark mode
                    color: isDark ? Colors.white : Colors.black87, 
                  ),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 12, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(durationStr, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Text("-Rp ${NumberFormat('#,###').format(cost)}",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}