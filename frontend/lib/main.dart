import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart'; // añade este import arriba

void main() {
  runApp(const MercaVisionApp());
}

class MercaVisionApp extends StatelessWidget {
  const MercaVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MercaVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/profile': (context) => const ProfileScreen(),

      },
    );
  }
}