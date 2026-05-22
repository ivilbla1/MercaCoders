import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/listening_screen.dart';
import 'screens/camera_recognition_screen.dart';
import 'services/product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B3C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Tamaño de texto base mayor para accesibilidad
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // Mínimo de contraste en botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56), // touch target grande
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/listening':
            return MaterialPageRoute(builder: (_) => const ListeningScreen());
          case '/camera':
            return MaterialPageRoute(builder: (_) => const CameraRecognitionScreen());
          case '/scan':
            // Acepta tanto List<String> (flujo antiguo) como Map con detalle
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final productos = List<String>.from(args['productos'] ?? []);
              final productosDetalle =
                  args['productosDetalle'] as List<ProductoDetalle>?;
              return MaterialPageRoute(
                builder: (_) => ScanScreen(
                  productos: productos,
                  productosDetalle: productosDetalle,
                ),
              );
            } else if (args is List<String>) {
              return MaterialPageRoute(
                builder: (_) => ScanScreen(productos: args),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const ScanScreen(productos: []),
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}