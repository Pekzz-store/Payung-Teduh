import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk Timestamp
import '../../../services/rental_service.dart';

class ActiveRentalCard extends StatefulWidget {
  final Map<String, dynamic> rentalData;
  final String rentalId;

  const ActiveRentalCard({
    super.key, 
    required this.rentalData, 
    required this.rentalId
  });

  @override
  State<ActiveRentalCard> createState() => _ActiveRentalCardState();
}

class _ActiveRentalCardState extends State<ActiveRentalCard> {
  Timer? _timer;
  String _durationString = "00:00:00";
  int _costEstimate = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  void _startTimer() {
    var startTs = widget.rentalData['startTime'];
    DateTime startTime = (startTs != null) ? (startTs as Timestamp).toDate() : DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { 
        timer.cancel();
        return;
      }

      DateTime now = DateTime.now();
      Duration diff = now.difference(startTime);

      setState(() {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        String hours = twoDigits(diff.inHours);
        String minutes = twoDigits(diff.inMinutes.remainder(60));
        String seconds = twoDigits(diff.inSeconds.remainder(60));
        _durationString = "$hours:$minutes:$seconds";

        // Estimasi biaya (Rp 5000/jam, minimal 1 jam)
        int hoursBilled = (diff.inMinutes / 60).ceil();
        if (hoursBilled < 1) hoursBilled = 1;
        _costEstimate = hoursBilled * 5000;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.blueAccent),
                const SizedBox(width: 10),
                const Text("Sewa Berjalan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                  child: const Text("ACTIVE", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(height: 30),
            
            // Timer Besar
            Text(_durationString, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
            const Text("Durasi Pemakaian", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 20),
            
            // Info Biaya
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Lokasi Awal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(widget.rentalData['stationName'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Estimasi Biaya", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Rp $_costEstimate", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Kembalikan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmReturn(context),
                icon: const Icon(Icons.assignment_return), 
                label: const Text("KEMBALIKAN PAYUNG"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmReturn(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kembalikan Payung?"),
        content: const Text("Pastikan Anda sudah berada di stasiun pengembalian."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog dulu
              
              try {
                // --- PERBAIKAN DI SINI: TAMBAHKAN USER ID ---
                await RentalService().returnRental(
                  rentalId: widget.rentalId,
                  stationId: widget.rentalData['stationId'],
                  userId: widget.rentalData['userId'], // Ambil dari data sewa
                );
                // -------------------------------------------
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Terima kasih! Payung dikembalikan."))
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal: $e"))
                  );
                }
              }
            },
            child: const Text("YA, KEMBALIKAN"),
          )
        ],
      ),
    );
  }
}