import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; 
import '../../database/db_helper.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final data = await DatabaseHelper.instance.getAllBookings();
    if (mounted) {
      setState(() {
        bookings = data.reversed.toList(); 
        _isLoading = false;
      });
    }
  }

  String _formatNomorWA(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      return '62${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('8')) {
      return '62$cleanPhone';
    }
    return cleanPhone;
  }

  void _kirimTiketKonfirmasi(Map<String, dynamic> item) async {
    String formattedPhone = _formatNomorWA(item['nomor_wa']);

    // Formatter untuk WhatsApp
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    String message = 
      "✅ *KONFIRMASI PEMESANAN TIKET* \n"
      "Terima kasih telah memesan di TFMSYR Trans.\n\n"
      "Berikut detail E-Tiket Anda:\n"
      "-----------------------------------------\n"
      "🎫 *KODE BOOKING:* #${item['id']} \n"
      "👤 *Penumpang:* ${item['nama_penumpang']} \n"
      "🚌 *Armada:* ${item['nama_bus']} \n"
      "🛣 *Rute:* ${item['rute']} \n"
      "📅 *Tanggal:* ${item['tanggal_berangkat'] ?? '-'} \n"
      "⏰ *Jam:* ${item['jam_berangkat'] ?? '-'} \n"
      "💺 *Kursi:* ${item['nomor_kursi'] ?? 'Belum Pilih'} \n"
      "📍 *Titik Jemput:* \n${item['lokasi_jemput'] ?? '-'} \n"
      "-----------------------------------------\n"
      // formatter di pesan WA
      "💰 *STATUS:* LUNAS (${currencyFormatter.format(item['harga'])})\n\n"
      "Harap tunjukkan pesan ini kepada kru saat boarding.\n"
      "Mohon hadir 30 menit sebelum keberangkatan.\n\n"
      "_Selamat menikmati perjalanan!_ 🚌💨";

    final Uri url = Uri.parse("https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka WhatsApp: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Daftar Pesanan Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF29B6F6),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        color: const Color(0xFF0288D1),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final item = bookings[index];
                  return _buildOrderCard(item);
                },
              ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> item) {
    // [BARU] Formatter untuk Tampilan UI
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1), 
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER KARTU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      "Order #${item['id']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50], 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[200]!)
                  ),
                  child: Text(
                    "LUNAS", 
                    style: TextStyle(fontSize: 10, color: Colors.green[700], fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),

          // ISI KARTU
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            item['nama_bus'], 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0277BD))
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.route, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['rute'], 
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Total Bayar", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          // [UBAH DISINI] Menggunakan formatter di UI
                          Text(
                            currencyFormatter.format(item['harga']), 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Colors.transparent, height: 10), 
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(Icons.calendar_today, "Tanggal", item['tanggal_berangkat'] ?? '-'),
                      _buildMiniInfo(Icons.event_seat, "Kursi", item['nomor_kursi'] ?? '-', isBold: true),
                      _buildMiniInfo(Icons.person, "Penumpang", item['nama_penumpang'], isTruncated: true),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['lokasi_jemput'] ?? 'Titik jemput tidak ditentukan',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _kirimTiketKonfirmasi(item),
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white), 
                    label: const Text("KIRIM E-TIKET (WA)", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value, {bool isBold = false, bool isTruncated = false}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.green[700]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        SizedBox(
          width: 80, 
          child: Text(
            value, 
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: isTruncated ? TextOverflow.ellipsis : TextOverflow.visible,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("Belum ada pesanan masuk", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}