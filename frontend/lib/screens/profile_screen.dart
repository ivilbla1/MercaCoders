import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              Color(0xFFF5EFE6),
              Color(0xFFEDE0D0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ── BARRA SUPERIOR ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 28,
                      color: Color(0xFF00874A),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00874A),
                      ),
                    ),
                  ],
                ),
              ),

              // ── ICONO PERFIL GRANDE ──────────────────────────
              const SizedBox(height: 24),
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Color(0xFF00874A),
              ),
              const SizedBox(height: 32),

              // ── CAMPOS DE DATOS ──────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _campoInfo(
                        icono: Icons.person_outline,
                        etiqueta: 'Nombre y apellidos',
                        valor: 'Ana García López',
                      ),
                      _campoInfo(
                        icono: Icons.email_outlined,
                        etiqueta: 'Correo electrónico',
                        valor: 'ana.garcia@email.com',
                      ),
                      _campoInfo(
                        icono: Icons.no_food_outlined,
                        etiqueta: 'Alérgenos',
                        valor: 'Gluten, Lactosa',
                      ),
                      _campoInfo(
                        icono: Icons.phone_outlined,
                        etiqueta: 'Contacto de asistencia',
                        valor: '+34 600 000 000',
                      ),
                    ],
                  ),
                ),
              ),

              // ── BOTÓN CERRAR SESIÓN ──────────────────────────
              Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: cerrar sesión
                    },
                    icon: const Icon(Icons.logout, size: 24, color: Colors.white),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET REUTILIZABLE PARA CADA CAMPO ─────────────────
  Widget _campoInfo({
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00874A).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icono, color: Color(0xFF00874A), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF2E2E2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}