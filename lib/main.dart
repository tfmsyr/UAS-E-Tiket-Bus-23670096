import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tfmsyr Trans',
      theme: ThemeData(
        primaryColor: const Color(0xFF1BA0E2), 
        scaffoldBackgroundColor: const Color(0xFFF5F6FA), 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1BA0E2),
          primary: const Color(0xFF1BA0E2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1BA0E2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1BA0E2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}