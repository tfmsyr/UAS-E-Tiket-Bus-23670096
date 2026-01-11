import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/bus_model.dart';

class BookingFormScreen extends StatefulWidget {
  final Bus bus;
  const BookingFormScreen({super.key, required this.bus});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaController = TextEditingController();
  final _waController = TextEditingController();
  final _tanggalController = TextEditingController();

  String? _selectedLokasi;
  String? _selectedSeat; 
  List<String> _titikJemputOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.bus.titikJemput.isNotEmpty) {
      _titikJemputOptions = widget.bus.titikJemput.split(',').map((e) => e.trim()).toList();
    } else {
      _titikJemputOptions = ['Pool Pusat'];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1BA0E2)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSeat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Silakan pilih kursi terlebih dahulu!"), backgroundColor: Colors.red)
        );
        return;
      }

      Map<String, dynamic> bookingData = {
        'nama_bus': widget.bus.namaBus,
        'rute': widget.bus.rute,
        'harga': widget.bus.harga,
        'nama_penumpang': _namaController.text,
        'nomor_wa': _waController.text,
        'tanggal_booking': DateTime.now().toString().split(' ')[0],
        'tanggal_berangkat': _tanggalController.text,
        'lokasi_jemput': _selectedLokasi,
        'nomor_kursi': _selectedSeat, 
      };

      await DatabaseHelper.instance.createBooking(bookingData);
      
      if (!mounted) return;

      Map<String, dynamic> ticketData = Map.from(bookingData);
      ticketData['jam_berangkat'] = widget.bus.jamBerangkat; 

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => BookingSuccessScreen(bookingData: ticketData))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalRows = (widget.bus.jumlahKursi / 4).ceil();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Form Pemesanan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1BA0E2),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Data Penumpang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1BA0E2))),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildInput(_namaController, "Nama Lengkap", Icons.person),
                      _buildInput(_waController, "Nomor WhatsApp", Icons.phone, isNumber: true),
                      
                      TextFormField(
                        controller: _tanggalController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (val) => val!.isEmpty ? "Pilih tanggal keberangkatan" : null,
                        decoration: InputDecoration(
                          labelText: "Tanggal Berangkat", 
                          prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFF1BA0E2)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: _selectedLokasi,
                        decoration: InputDecoration(
                          labelText: "Titik Jemput", 
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1BA0E2)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _titikJemputOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (v) => setState(() => _selectedLokasi = v),
                        validator: (v) => v == null ? "Pilih lokasi jemput" : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Pilih Kursi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1BA0E2))),
                      const SizedBox(height: 5),
                      Text("Total Kapasitas: ${widget.bus.jumlahKursi} Kursi", style: const TextStyle(color: Colors.grey)),
                      const Divider(),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legend(Colors.grey[300]!, "Tersedia"),
                          const SizedBox(width: 20),
                          _legend(const Color(0xFF1BA0E2), "Dipilih"),
                          const SizedBox(width: 20),
                          _legend(Colors.red[100]!, "Terisi"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)
                        ),
                        alignment: Alignment.centerRight,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("SUPIR  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Icon(Icons.sports_motorsports, color: Colors.grey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            for (int i = 1; i <= totalRows; i++) _buildRowSeat(i, widget.bus.jumlahKursi)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BA0E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text("KONFIRMASI PEMESANAN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowSeat(int row, int maxSeats) {
    int start = (row - 1) * 4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _seatItem("A$row", start + 1, maxSeats),
              const SizedBox(width: 8),
              _seatItem("B$row", start + 2, maxSeats),
            ],
          ),
          
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text("$row", style: TextStyle(color: Colors.grey[300], fontSize: 12)),
          ), 
          
          Row(
            children: [
              _seatItem("C$row", start + 3, maxSeats),
              const SizedBox(width: 8),
              _seatItem("D$row", start + 4, maxSeats),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seatItem(String label, int index, int max) {
    if (index > max) return const SizedBox(width: 45, height: 45);
    
    bool selected = _selectedSeat == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedSeat = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1BA0E2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF1BA0E2) : Colors.grey.shade300,
            width: 2
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3), // UPDATED: withValues
              blurRadius: 8, 
              spreadRadius: 1
            )
          ] : [],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair, size: 20, color: selected ? Colors.white : Colors.grey[400]),
            Text(
              label, 
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[600], 
                fontWeight: FontWeight.bold, 
                fontSize: 10
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color c, String t) => Row(
    children: [
      Container(
        width: 16, height: 16, 
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))
      ), 
      const SizedBox(width: 6), 
      Text(t, style: const TextStyle(fontSize: 12))
    ]
  );

  Widget _buildInput(TextEditingController c, String l, IconData i, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c, 
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
        decoration: InputDecoration(
          labelText: l, 
          prefixIcon: Icon(i, color: const Color(0xFF1BA0E2)), 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingSuccessScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final String bookingId = "TFM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    String hargaFormatted = double.parse(bookingData['harga'].toString()).toStringAsFixed(0);
    String jamReal = bookingData['jam_berangkat'] ?? "-";

    return Scaffold(
      backgroundColor: const Color(0xFF1BA0E2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 80),
              const SizedBox(height: 15),
              const Text(
                "Pemesanan Berhasil!",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Tiket elektronik Anda telah terbit.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2), // UPDATED: withValues
                      blurRadius: 15, 
                      offset: const Offset(0, 10)
                    )
                  ]
                ),
                child: Column(
                  children: [
                    // Header Tiket
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TFMSYR TRANS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(5)),
                            child: Text(bookingId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),

                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ticketRow("Nama Penumpang", bookingData['nama_penumpang']),
                          const SizedBox(height: 15),
                          _ticketRow("Armada Bus", bookingData['nama_bus']),
                          const SizedBox(height: 15),
                          _ticketRow("Rute Perjalanan", bookingData['rute']),
                          const SizedBox(height: 25),
                          const Divider(color: Colors.grey), 
                          const SizedBox(height: 10),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ticketColumn("Tanggal", bookingData['tanggal_berangkat']),
                              _ticketColumn("Jam", jamReal),
                              _ticketColumn("Kursi", bookingData['nomor_kursi']),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        border: Border(top: BorderSide(color: Colors.grey.shade200))
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_2, size: 60),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Scan saat boarding", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text("Total Bayar: Rp $hargaFormatted", style: const TextStyle(color: Color(0xFF1BA0E2), fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("KEMBALI KE BERANDA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _ticketColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}