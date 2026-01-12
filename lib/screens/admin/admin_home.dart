import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/bus_model.dart';
import '../auth/login_screen.dart';
import 'bus_form.dart';
import 'admin_orders.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Bus> _buses = [];
  bool _isLoading = true;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // --- LOGIC: Fetch Data dari Database ---
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    // Mengambil data bus dan booking dari database lokal
    final dataBus = await DatabaseHelper.instance.readAllBuses();
    final dataOrder = await DatabaseHelper.instance.getAllBookings();

    if (mounted) {
      setState(() {
        _buses = dataBus;
        _orderCount = dataOrder.length;
        _isLoading = false;
      });
    }
  }

  // --- LOGIC: Format Mata Uang (Rupiah) ---
  String _formatCurrency(double price) {
    String priceStr = price.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }
    return 'Rp $result';
  }

  // --- LOGIC: Logout & Delete ---
  void _logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _deleteBus(int id) async {
    await DatabaseHelper.instance.deleteBus(id);
    _refreshData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data bus berhasil dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(), // Menu Samping
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // --- 1. HEADER (Gradient Background) ---
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),

                // --- 2. KONTEN UTAMA (Scrollable) ---
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Dashboard (Judul & Logout)
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(builder: (context) {
                                  return IconButton(
                                    icon: const Icon(Icons.menu,
                                        color: Colors.white, size: 28),
                                    onPressed: () =>
                                        Scaffold.of(context).openDrawer(),
                                  );
                                }),
                                const Text(
                                  "Dashboard Admin",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout,
                                      color: Colors.white, size: 26),
                                  onPressed: _logout,
                                )
                              ],
                            ),
                          ),

                          // Teks Selamat Datang
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Selamat Datang,",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Admin Manager",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 35),

                          // Kartu Statistik (Total Armada & Pesanan)
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.directions_bus_filled_rounded,
                                  color: Colors.blueAccent,
                                  label: "Total Armada",
                                  value: "${_buses.length}",
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.receipt_long_rounded,
                                  color: Colors.orange,
                                  label: "Pesanan Masuk",
                                  value: "$_orderCount",
                                  isAlert: _orderCount > 0,
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AdminOrdersScreen()));
                                    _refreshData();
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Header List Bus
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Daftar Armada",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade100)),
                                  child: Text(
                                    "${_buses.length} Unit",
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // List Bus (Daftar Kartu)
                          _buses.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _buses.length,
                                  itemBuilder: (context, index) {
                                    final bus = _buses[index];
                                    return _buildBusCard(bus);
                                  },
                                ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      // Tombol Tambah Bus (+)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const BusFormScreen()));
          _refreshData();
        },
        backgroundColor: const Color(0xFF0288D1),
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: const Text("Tambah Bus",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  // --- WIDGET: Kartu Statistik Kecil ---
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isAlert = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                if (isAlert)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: Kartu Detail Bus ---
  Widget _buildBusCard(Bus bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFE3F2FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(33, 150, 243, 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.namaBus,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 50,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bus.rute,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Tarif",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined,
                              size: 16, color: Colors.black87),
                          const SizedBox(width: 4),
                          Text(
                            _formatCurrency(bus.harga),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event_seat,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            "${bus.jumlahKursi} Seat Tersedia",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(68, 138, 255, 0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Positioned(
                          right: 10,
                          child: Icon(
                            Icons.directions_bus_filled_rounded,
                            size: 80,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 0,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BusFormScreen(bus: bus)))
                      .then((_) => _refreshData());
                } else if (value == 'delete') {
                  _deleteBus(bus.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 10),
                    Text("Edit")
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Hapus")
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Drawer (Menu Samping) ---
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            accountName: const Text("Admin Manager",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            accountEmail: const Text("admin@tfmsyr.com",
                style: TextStyle(fontSize: 14, color: Colors.white70)),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 10)
                  ]),
              child: const Icon(Icons.person_rounded,
                  size: 45, color: Color(0xFF0288D1)),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded,
                color: Colors.blue, size: 28),
            title: const Text('Dashboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded,
                color: Colors.black54, size: 28),
            title: const Text('Pesanan Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            trailing: _orderCount > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text("$_orderCount",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminOrdersScreen()))
                  .then((_) => _refreshData());
            },
          ),
          const Spacer(),
          const Divider(thickness: 1),
          ListTile(
            leading:
                const Icon(Icons.logout_rounded, color: Colors.red, size: 28),
            title: const Text('Logout',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            onTap: _logout,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET: Tampilan Saat Kosong ---
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.only(top: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.directions_bus_outlined,
              size: 100, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("Belum ada armada bus",
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("Tekan tombol + untuk menambah",
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}