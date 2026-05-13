import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Colores accesibles según guías ONCE / WCAG 2.1 AAA
/// Ratio de contraste mínimo 7:1 sobre fondos usados
class AppColors {
  // Fondo principal: blanco puro
  static const Color fondo       = Color(0xFFFFFFFF);
  // Verde Mercadona (ratio ~5.3 sobre blanco; sobre negro >10)
  static const Color verde       = Color(0xFF006B3C);   // ligeramente más oscuro para AAA
  // Amarillo alto contraste (ONCE: negro sobre amarillo es máxima visibilidad)
  static const Color amarillo    = Color(0xFFFFD700);
  // Texto principal: casi negro
  static const Color textoPrincipal = Color(0xFF1A1A1A);
  // Texto secundario
  static const Color textoSecundario = Color(0xFF4A4A4A);
  // Borde de tarjeta
  static const Color borde       = Color(0xFF006B3C);
  // Botón de acción secundario
  static const Color rojoAccion  = Color(0xFFC0392B);
  // Fondo tarjeta translúcida
  static const Color fondoTarjeta = Color(0xFFF2F8F4);
}

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
    // Pequeño delay para que la pantalla cargue antes de hablar
    Future.delayed(const Duration(milliseconds: 800), _anunciarPantalla);
  }

  Future<void> _configurarTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _anunciarPantalla() async {
    await _tts.speak(
      'Bienvenido a MercaVision. '
      'Pantalla de inicio. '
      'Tienes dos botones en la barra superior: Configuración a la izquierda y Perfil a la derecha. '
      'En el centro hay un botón grande de micrófono. '
      'Pulsa el micrófono para empezar a dictar tu lista de la compra.',
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
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [

            // ── BARRA SUPERIOR ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BotonAccesible(
                    icono: Icons.settings_outlined,
                    etiqueta: 'Configuración',
                    descripcionVoz: 'Botón Configuración',
                    onTap: () => _hablar('Configuración. Próximamente disponible.'),
                  ),
                  // Logo / título centrado
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _anunciarPantalla(),
                      child: Center(
                        child: Text(
                          'MercaVision',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.verde,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BotonAccesible(
                    icono: Icons.account_circle_outlined,
                    etiqueta: 'Mi perfil',
                    descripcionVoz: 'Botón Mi perfil',
                    onTap: () {
                      _hablar('Abriendo mi perfil.');
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ],
              ),
            ),

            // ── SUBTÍTULO ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borde.withOpacity(0.3)),
                ),
                child: Semantics(
                  label: 'Aplicación de compra autónoma para personas con discapacidad visual',
                  child: Text(
                    'Compra autónoma guiada por voz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textoSecundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── LOGO ──────────────────────────────────────────────────────────
            Semantics(
              label: 'Logo MercaVision',
              child: Image.asset(
                'assets/mercaVision.jpg',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.storefront,
                  size: 120,
                  color: AppColors.verde,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── INSTRUCCIÓN ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Pulsa el micrófono y di tu lista de la compra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoPrincipal,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── BOTÓN MICRÓFONO PRINCIPAL ─────────────────────────────────────
            Semantics(
              button: true,
              label: 'Botón micrófono. Pulsa para dictar tu lista de la compra',
              child: GestureDetector(
                onTap: () {
                  _hablar('Abriendo reconocimiento de voz. Di tu lista de la compra.');
                  Navigator.pushNamed(context, '/listening');
                },
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppColors.verde,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.amarillo, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.verde.withOpacity(0.4),
                        blurRadius: 48,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── TEXTO BAJO EL BOTÓN ───────────────────────────────────────────
            Text(
              'COMENZAR COMPRA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.verde,
                letterSpacing: 2,
              ),
            ),

            const Spacer(),

            // ── BOTÓN REPETIR INSTRUCCIONES ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Semantics(
                button: true,
                label: 'Botón repetir instrucciones de la pantalla',
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _anunciarPantalla,
                    icon: const Icon(Icons.volume_up, size: 28),
                    label: const Text(
                      'Repetir instrucciones',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.verde,
                      side: BorderSide(color: AppColors.verde, width: 2.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WIDGET REUTILIZABLE: botón accesible barra superior ──────────────────────
class _BotonAccesible extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String descripcionVoz;
  final VoidCallback onTap;

  const _BotonAccesible({
    required this.icono,
    required this.etiqueta,
    required this.descripcionVoz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: descripcionVoz,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borde.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 36, color: AppColors.verde),
              const SizedBox(height: 4),
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.verde,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}