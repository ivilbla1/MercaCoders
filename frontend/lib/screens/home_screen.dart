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
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFEDE0D0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                      iconSize: 40,
                      color: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.all(12),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const Icon(Icons.account_circle_outlined),
                      iconSize: 44,
                      color: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.all(12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Image.asset(
                'assets/mercaVision.jpg',
                height: 220,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),
              const Text(
                'Comenzar compra',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/listening'),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.35),
                        blurRadius: 44,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 140,
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