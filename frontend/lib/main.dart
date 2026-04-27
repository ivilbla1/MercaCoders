import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart'; // añade este import arriba
import 'screens/listening_screen.dart'; // añade arriba
import 'screens/scan_screen.dart'; // añade arriba

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
        '/profile': (context) => const ProfileScreen(),
        '/listening': (context) => const ListeningScreen(),
        '/scan': (context) => ScanScreen(productos: ModalRoute.of(context)!.settings.arguments as List<String>,
),
      
      },
    );
  }
}