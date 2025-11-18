import 'package:flutter/material.dart';
import '../../../services/wallet_service.dart';

class TopUpSheet extends StatefulWidget {
  final String userId;
  const TopUpSheet({super.key, required this.userId});

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  // Pilihan nominal yang tersedia
  final List<int> amounts = [10000, 20000, 50000, 100000];
  int? selectedAmount; // Nominal yang dipilih user
  bool isLoading = false;

  void _processTopUp() async {
    if (selectedAmount == null) return;

    setState(() => isLoading = true);
    try {
      await WalletService().topUpBalance(
        userId: widget.userId, 
        amount: selectedAmount!
      );
      
      if (mounted) {
        Navigator.pop(context); // Tutup Sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Berhasil isi saldo Rp $selectedAmount"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Handle
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          
          const Text("Isi Saldo (Top Up)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Pilih nominal yang ingin ditambahkan", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // Grid Pilihan Nominal
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Kolom
                childAspectRatio: 2.5, // Lebar vs Tinggi
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: amounts.length,
              itemBuilder: (context, index) {
                int value = amounts[index];
                bool isSelected = selectedAmount == value;

                return GestureDetector(
                  onTap: () => setState(() => selectedAmount = value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Rp $value",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tombol Bayar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (selectedAmount != null && !isLoading) ? _processTopUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("BAYAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}