import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // [BARU] Import library intl
import '../../models/bus_model.dart';
import 'booking_form.dart'; 

class BusDetailScreen extends StatelessWidget {
  final Bus bus;
  const BusDetailScreen({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    // [BARU] Membuat formatter Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    List<String> fasilitas = bus.fasilitas.isNotEmpty ? bus.fasilitas.split(',') : [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
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
              background: _buildHeaderImage(bus.fotoUrl), 
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      // [UBAH DISINI] Menggunakan formatter
                      Text(
                        currencyFormatter.format(bus.harga), 
                        style: const TextStyle(fontSize: 20, color: Color(0xFF1BA0E2), fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

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

                  const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(bus.deskripsi, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 20),

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

                  const Text("Titik Jemput", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bus.titikJemput, style: const TextStyle(color: Colors.black87))),
                    ],
                  ),

                  const SizedBox(height: 80), 
                ],
              ),
            ),
          )
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Jika error gunakan .withValues(alpha: 0.1) untuk Flutter terbaru
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormScreen(bus: bus)));
            },
            child: const Text("PESAN TIKET SEKARANG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

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