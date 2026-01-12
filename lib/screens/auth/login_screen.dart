import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/db_helper.dart';
import '../admin/admin_home.dart';
import '../user/user_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  bool _isObscure = true;   // Untuk menyembunyikan password
  bool _isLoading = false;  // Untuk status loading saat login diproses

  // Fungsi Login
  void _login() async {
    // 1. Validasi Input Kosong
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi Username dan Password'),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }

    // 2. Set status loading true (tombol jadi loading)
    setState(() {
      _isLoading = true;
    });

    // 3. Cek ke Database (Simulasi delay dikit biar kerasa loadingnya jika perlu)
    final user = await DatabaseHelper.instance.login(
      _userController.text, 
      _passController.text
    );

    // 4. Cek Hasil
    if (user != null) {
      // Login Berhasil -> Simpan Sesi
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', user['role']);
      await prefs.setString('username', user['username']);

      if (!mounted) return;

      // Reset loading (opsional karena mau pindah layar)
      setState(() {
        _isLoading = false;
      });

      // Navigasi sesuai Role
      if (user['role'] == 'admin') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
      }
    } else {
      // Login Gagal
      if (!mounted) return;
      
      setState(() {
        _isLoading = false; // Matikan loading
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username atau Password Salah!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false, // Hapus ini agar keyboard tidak menutupi input
      body: Stack(
        children: [
          // --- 1. BACKGROUND GRADIENT ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF29B6F6), // Light Blue
                  Color(0xFF039BE5), // Medium Blue
                  Color(0xFF0277BD), // Dark Blue
                ],
              ),
            ),
          ),

          // --- 2. CONTENT (CENTERED) ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 
                  // WIDGET KACA (GLASSMORPHISM)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      // Filter Blur dari dart:ui
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), 
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          // Transparansi background kaca
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/logo_bus.png',
                              width: 100,
                              height: 100,
                              color: Colors.white,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.directions_bus, size: 80, color: Colors.white);
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "TFMSYR TRANS",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black12,
                                        blurRadius: 4)
                                  ]),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Perjalanan Nyaman & Terpercaya",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 30),

                            // FORM INPUT
                            _buildGlassTextField(
                              controller: _userController,
                              icon: Icons.person_outline_rounded,
                              hint: "Username",
                            ),
                            const SizedBox(height: 15),
                            _buildGlassTextField(
                              controller: _passController,
                              icon: Icons.lock_outline_rounded,
                              hint: "Password",
                              isPassword: true,
                            ),

                            const SizedBox(height: 30),

                            // TOMBOL LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login, // Disable jika loading
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0277BD),
                                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: _isLoading 
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2)
                                    )
                                  : const Text(
                                      "MASUK",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Text Field gaya Kaca
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _isObscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white70, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _isObscure = !_isObscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}