import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // [BARU] Tambahkan import ini
import '../../database/db_helper.dart';
import '../../models/bus_model.dart';
import '../auth/login_screen.dart';
import 'bus_detail.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<Bus> buses = [];
  List<Bus> filteredBuses = [];
  String username = "";
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBuses();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => username = prefs.getString('username') ?? "User");
  }

  Future<void> _refreshBuses() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.readAllBuses();
    if (mounted) {
      setState(() {
        buses = data;
        filteredBuses = data;
        isLoading = false;
      });
    }
  }

  void _runFilter(String keyword) {
    List<Bus> results = [];
    if (keyword.isEmpty) {
      results = buses;
    } else {
      results = buses
          .where((bus) =>
              bus.namaBus.toLowerCase().contains(keyword.toLowerCase()) ||
              bus.rute.toLowerCase().contains(keyword.toLowerCase()) ||
              bus.titikJemput.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() => filteredBuses = results);
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [BARU] Membuat formatter mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Tfmsyr Trans", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1BA0E2),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: Column(
        children: [
          // HEADER AREA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF1BA0E2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $username!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Mau pergi ke mana hari ini?",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  onChanged: _runFilter,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Cari tujuan anda",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          // LIST BUS 
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBuses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text("Belum ada armada tersedia", style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: filteredBuses.length,
                        itemBuilder: (context, index) {
                          final bus = filteredBuses[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BusDetailScreen(bus: bus)),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1), // Menggunakan withOpacity agar aman untuk versi flutter lama/baru
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FOTO BUS
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: _buildBusImage(bus.fotoUrl),
                                      ),
                                    ),
                                  ),
                                  
                                  // INFO BUS
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Nama Bus
                                              Text(
                                                bus.namaBus,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),

                                              // Jam
                                              Row(
                                                children: [
                                                  const Icon(Icons.access_time, size: 12, color: Colors.blueAccent),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      bus.jamBerangkat,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.blueAccent,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),

                                              // Rute
                                              Text(
                                                bus.rute,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),

                                          // Harga [BAGIAN YANG DIPERBAIKI]
                                          Text(
                                            currencyFormatter.format(bus.harga),
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.blue.shade50,
        child: const Center(child: Icon(Icons.directions_bus, size: 40, color: Colors.blueAccent)),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }
}