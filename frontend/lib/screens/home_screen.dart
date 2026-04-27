import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color(0xFFEDE0D0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ── BARRA SUPERIOR ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                      iconSize: 40,
                      color: Color(0xFF00874A),   // verde Mercadona
                      padding: const EdgeInsets.all(12),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const Icon(Icons.account_circle_outlined),
                      iconSize: 44,
                      color: Color(0xFF00874A),   // verde Mercadona
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ),
              ),

              // ── LOGO ─────────────────────────────────────────
              const SizedBox(height: 16),
              Image.asset(
                'assets/mercaVision.jpg',
                height: 220,
                fit: BoxFit.contain,
              ),

              // ── COMENZAR COMPRA ──────────────────────────────
              const SizedBox(height: 32),
              const Text(
                'Comenzar compra',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00874A),       // verde Mercadona
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── BOTÓN MICRÓFONO ──────────────────────────────
              GestureDetector(
                onTap: () {
                  // TODO: activar voz
                },
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00874A), // verde Mercadona
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00874A).withOpacity(0.35),
                        blurRadius: 44,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 140,                      // micro grande
                    color: Colors.white,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}