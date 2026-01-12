import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // [PENTING] Library format uang
import '../../models/bus_model.dart';
import 'booking_form.dart'; 

class BusDetailScreen extends StatelessWidget {
  final Bus bus;
  const BusDetailScreen({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    // --- 1. SETUP FORMATTER RUPIAH ---
    // Mengubah angka 150000 menjadi "Rp 150.000"
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    // --- 2. UBAH STRING "AC,WIFI,TV" JADI LIST ---
    // Memisahkan teks fasilitas berdasarkan koma agar bisa dibuat kotak-kotak (Chips)
    List<String> fasilitas = bus.fasilitas.isNotEmpty ? bus.fasilitas.split(',') : [];

    return Scaffold(
      // --- 3. SCROLL VIEW DENGAN EFEK HEADER ---
      body: CustomScrollView(
        slivers: [
          // HEADER GAMBAR YANG BISA MENYUSUT (Parallax)
          SliverAppBar(
            expandedHeight: 250,
            pinned: true, // Header tetap nempel di atas saat scroll
            backgroundColor: const Color(0xFF1BA0E2),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                bus.namaBus, 
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)]
                )
              ),
              background: _buildHeaderImage(bus.fotoUrl), // Gambar Bus
            ),
          ),

          // BODY KONTEN DETAIL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INFORMASI UTAMA (RUTE & HARGA) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Rute Perjalanan", style: TextStyle(color: Colors.grey)),
                            Text(bus.rute, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Tampilkan Harga
                      Text(
                        currencyFormatter.format(bus.harga), 
                        style: const TextStyle(fontSize: 20, color: Color(0xFF1BA0E2), fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- INFO JAM KEBERANGKATAN ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Berangkat: ${bus.jamBerangkat}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 30),

                  // --- DESKRIPSI ---
                  const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(bus.deskripsi, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 20),

                  // --- FASILITAS (TAMPILAN CHIPS) ---
                  const Text("Fasilitas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fasilitas.map((f) => Chip(
                      avatar: const Icon(Icons.check_circle, size: 16, color: Colors.blue),
                      label: Text(f.trim(), style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // --- TITIK JEMPUT ---
                  const Text("Titik Jemput", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bus.titikJemput, style: const TextStyle(color: Colors.black87))),
                    ],
                  ),

                  const SizedBox(height: 80), // Ruang kosong agar tidak tertutup tombol bawah
                ],
              ),
            ),
          )
        ],
      ),
      
      // --- TOMBOL PESAN (DI BAWAH LAYAR) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 10, 
              offset: const Offset(0, -5)
            )
          ]
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BA0E2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Pindah ke Form Pemesanan
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormScreen(bus: bus)));
            },
            child: const Text("PESAN TIKET SEKARANG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // --- LOGIC CEK GAMBAR (INTERNET VS LOKAL) ---
  Widget _buildHeaderImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.blue.shade100, 
        child: const Center(child: Icon(Icons.directions_bus, size: 80, color: Colors.white))
      );
    }

    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(
        File(path), 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          );
        },
      );
    }
  }
}