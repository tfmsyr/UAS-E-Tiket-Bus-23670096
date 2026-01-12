// --- IMPORT LIBRARY & HALAMAN ---
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'auth/login_screen.dart';
import 'admin/admin_home.dart';
import 'user/user_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // --- VARIABEL ANIMASI ---
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // --- SETUP ANIMASI BERDENYUT ---
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), 
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true); // Animasi berulang (membesar-mengecil)
    _checkSession(); // Jalankan pengecekan login
  }

  @override
  void dispose() {
    _controller.dispose(); // Mencegah kebocoran memori
    super.dispose();
  }

  // --- LOGIC CEK STATUS LOGIN (SESSION) ---
  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3)); // Tahan logo selama 3 detik

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role'); // Ambil data "role" dari HP

    if (!mounted) return;
    
    _controller.stop(); // Hentikan animasi sebelum pindah

    // Cek apakah Admin, User Biasa, atau Belum Login
    if (role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
    } else if (role == 'user') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
    } else {
      // Jika belum login, arahkan ke Login Screen dengan efek Fade
      Navigator.pushReplacement(
        context, 
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // --- BACKGROUND GRADASI BIRU ---
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF29B6F6), 
              Color(0xFF039BE5), 
              Color(0xFF0277BD), 
            ],
          ),
        ),
        child: Center(
          // --- PENERAPAN ANIMASI PADA LOGO ---
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // --- EFEK CAHAYA (GLOW) ---
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: Image.asset(
                'assets/images/logo_bus.png',
                width: 150,
                height: 150,
                color: Colors.white, 
              ),
            ),
          ),
        ),
      ),
    );
  }
}