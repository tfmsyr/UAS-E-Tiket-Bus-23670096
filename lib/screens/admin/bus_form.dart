import 'dart:io'; // Wajib untuk menangani File gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Plugin Image Picker
import '../../database/db_helper.dart';
import '../../models/bus_model.dart';

class BusFormScreen extends StatefulWidget {
  final Bus? bus;
  const BusFormScreen({super.key, this.bus});

  @override
  State<BusFormScreen> createState() => _BusFormScreenState();
}

class _BusFormScreenState extends State<BusFormScreen> {
  // Controller
  final _namaController = TextEditingController();
  final _ruteController = TextEditingController();
  final _hargaController = TextEditingController();
  final _descController = TextEditingController();
  final _kursiController = TextEditingController();
  final _titikJemputController = TextEditingController();

  String? _selectedTime;
  File? _imageFile; // Variabel untuk menampung file foto dari galeri
  String? _currentFotoPath; // Menyimpan path foto lama jika sedang edit

  final List<String> _timeOptions = [
    "Pagi (06:00 WIB)", "Pagi (07:00 WIB)", "Pagi (08:00 WIB)",
    "Siang (13:00 WIB)", "Sore (16:00 WIB)", "Sore (17:00 WIB)",
    "Malam (19:00 WIB)", "Malam (20:00 WIB)",
  ];

  // --- UPDATE: Menambahkan "Sleeper" ke dalam daftar fasilitas ---
  final List<String> _allFacilities = [
    "AC", "Toilet", "Makan", "WiFi", "Selimut", "Bantal", 
    "Charging Port", "TV", "Leg Rest", "Sleeper", "Smoking Area"
  ];

  List<String> _selectedFacilities = [];

  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _namaController.text = widget.bus!.namaBus;
      _ruteController.text = widget.bus!.rute;
      
      // Tampilkan harga tanpa desimal .0 jika bulat
      _hargaController.text = widget.bus!.harga.toStringAsFixed(0); 
      
      _descController.text = widget.bus!.deskripsi;
      _kursiController.text = widget.bus!.jumlahKursi.toString();
      _titikJemputController.text = widget.bus!.titikJemput;

      // Logic Foto: Cek apakah ada foto lama
      if (widget.bus!.fotoUrl != null && widget.bus!.fotoUrl!.isNotEmpty) {
        _currentFotoPath = widget.bus!.fotoUrl;
        // Jika path bukan URL internet, kita load sebagai File
        if (!_currentFotoPath!.startsWith('http')) {
          _imageFile = File(_currentFotoPath!);
        }
      }

      if (_timeOptions.contains(widget.bus!.jamBerangkat)) {
        _selectedTime = widget.bus!.jamBerangkat;
      }

      if (widget.bus!.fasilitas.isNotEmpty) {
        _selectedFacilities = widget.bus!.fasilitas.split(',');
      }
    }
  }

  // --- FUNGSI AMBIL GAMBAR ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Pilih dari Galeri
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan file sementara
        _currentFotoPath = pickedFile.path; // Update path string
      });
    }
  }

  void _saveBus() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama Bus dan Harga wajib diisi!"), backgroundColor: Colors.red)
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Jam Keberangkatan!"), backgroundColor: Colors.red)
      );
      return;
    }

    // Bersihkan format harga & Konversi tipe data
    String hargaBersih = _hargaController.text.replaceAll('.', '').replaceAll(',', '');
    double? hargaFinal = double.tryParse(hargaBersih); 
    int? kursiFinal = int.tryParse(_kursiController.text);
    
    String fasilitasString = _selectedFacilities.join(',');

    final bus = Bus(
      id: widget.bus?.id,
      namaBus: _namaController.text,
      rute: _ruteController.text,
      harga: hargaFinal ?? 0.0,
      deskripsi: _descController.text,
      fasilitas: fasilitasString,
      jumlahKursi: kursiFinal ?? 30,
      titikJemput: _titikJemputController.text,
      
      // SIMPAN PATH FOTO DI SINI
      fotoUrl: _currentFotoPath, 
      
      jamBerangkat: _selectedTime!, 
    );

    try {
      if (widget.bus == null) {
        await DatabaseHelper.instance.createBus(bus);
      } else {
        await DatabaseHelper.instance.updateBus(bus);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Tersimpan!"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bus == null ? 'Tambah Armada' : 'Edit Armada'),
        backgroundColor: const Color(0xFF1BA0E2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INPUT FOTO ---
            _buildSectionTitle("Foto Armada"),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : (_currentFotoPath != null && _currentFotoPath!.startsWith('http')) 
                        ? Image.network(_currentFotoPath!, fit: BoxFit.cover) // Support foto lama yg online
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 5),
                              Text("Ketuk untuk upload foto", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Informasi Utama"),
            _buildInput("Nama PO Bus", _namaController, Icons.directions_bus),
            _buildInput("Rute (Asal - Tujuan)", _ruteController, Icons.map),
            
            // Dropdown Jam
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedTime,
                decoration: InputDecoration(
                  labelText: "Jam Keberangkatan",
                  prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _timeOptions.map((String time) {
                  return DropdownMenuItem<String>(value: time, child: Text(time));
                }).toList(),
                onChanged: (v) => setState(() => _selectedTime = v),
              ),
            ),

            Row(
              children: [
                Expanded(child: _buildInput("Harga Tiket", _hargaController, Icons.money, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildInput("Jml Kursi", _kursiController, Icons.event_seat, isNumber: true)),
              ],
            ),

            const SizedBox(height: 10),
            _buildSectionTitle("Fasilitas"),
            Wrap(
              spacing: 8.0,
              children: _allFacilities.map((facility) {
                return FilterChip(
                  label: Text(facility),
                  selected: _selectedFacilities.contains(facility),
                  onSelected: (bool selected) {
                    setState(() {
                      selected ? _selectedFacilities.add(facility) : _selectedFacilities.remove(facility);
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            _buildInput("Titik Penjemputan", _titikJemputController, Icons.location_on, maxLines: 2),
            _buildInput("Deskripsi", _descController, Icons.description, maxLines: 2),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveBus, 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1BA0E2), foregroundColor: Colors.white),
                child: const Text('SIMPAN DATA', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}