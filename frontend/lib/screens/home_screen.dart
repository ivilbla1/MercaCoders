import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

const _verde = Color(0xFF2E7D32);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _configurarTts();
    Future.delayed(const Duration(milliseconds: 800), _anunciarPantalla);
  }

  Future<void> _configurarTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
  }

  Future<void> _anunciarPantalla() async {
    await _tts.speak(
      'Bienvenido a MercaVision. '
      'Tienes dos botones en la barra superior: Configuración a la izquierda y Perfil a la derecha. '
      'Pulsa el botón grande del micrófono para empezar a dictar tu lista de la compra.',
    );
  }

  Future<void> _hablar(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final microSize = h * 0.35;

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

              // ── BARRA SUPERIOR ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BotonAccesible(
                      icono: Icons.settings_outlined,
                      etiqueta: 'Ajustes',
                      onTap: () => _hablar('Configuración. Próximamente disponible.'),
                    ),
                    _BotonAccesible(
                      icono: Icons.account_circle_outlined,
                      etiqueta: 'Perfil',
                      onTap: () {
                        _hablar('Abriendo mi perfil.');
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
              ),

              // ── LOGO ─────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/mercaVision.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront, size: 120, color: _verde,
                  ),
                ),
              ),

              // ── TEXTO ────────────────────────────────────────
              const Text(
                'Comenzar compra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── BOTÓN MICRÓFONO ──────────────────────────────
              GestureDetector(
                onTap: () {
                  _hablar('Abriendo reconocimiento de voz.');
                  Navigator.pushNamed(context, '/listening');
                },
                child: Container(
                  width: microSize,
                  height: microSize,
                  decoration: BoxDecoration(
                    color: _verde,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _verde.withOpacity(0.35),
                        blurRadius: 44,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic,
                    size: microSize * 0.5,
                    color: Colors.white,
                  ),
                ),
              ),

              const Spacer(),

              // ── BOTÓN REPETIR INSTRUCCIONES ──────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _anunciarPantalla,
                    icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
                    label: const Text(
                      'Repetir instrucciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
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
}

class _BotonAccesible extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _BotonAccesible({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _verde,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 36, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}