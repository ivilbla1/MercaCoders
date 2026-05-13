import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/voice_service.dart';
import '../services/product_service.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final VoiceService _voiceService = VoiceService();
  final ProductService _productService = ProductService();

  String _textoDetectado = '';
  bool _escuchando = false;
  bool _procesando = false;
  String _mensajeProcesando = '';
  late AnimationController _animController;
  late Animation<double> _animScale;

  // Colores accesibles
  static const _verde    = Color(0xFF006B3C);
  static const _amarillo = Color(0xFFFFD700);
  static const _fondo    = Color(0xFFFFFFFF);
  static const _texto    = Color(0xFF1A1A1A);
  static const _gris     = Color(0xFF5A5A5A);
  static const _rojo     = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _configurarTts();
    Future.delayed(const Duration(milliseconds: 600), _anunciarPantalla);
  }

  Future<void> _configurarTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
  }

  Future<void> _anunciarPantalla() async {
    await _tts.speak(
      'Pantalla de lista de la compra. '
      'Pulsa el botón rojo grande para empezar a dictar. '
      'Di algo como: quiero leche, pan y tomates. '
      'Cuando termines de hablar, pulsa el botón de nuevo para parar.',
    );
  }

  Future<void> _iniciarEscucha() async {
    await _tts.speak('Escuchando. Di tu lista.');
    await _voiceService.inicializar();
    setState(() {
      _escuchando = true;
      _textoDetectado = '';
    });
    await _voiceService.escuchar(
      onResultado: (texto) {
        setState(() {
          _textoDetectado = texto;
          _escuchando = false;
        });
        _animController.stop();
        _tts.speak('Has dicho: $texto. Pulsa Confirmar lista para continuar, o el micrófono para repetir.');
      },
    );
  }

  Future<void> _parar() async {
    await _voiceService.parar();
    _animController.stop();
    setState(() => _escuchando = false);
    await _tts.speak('Reconocimiento parado.');
  }

  Future<void> _confirmar() async {
    if (_textoDetectado.isEmpty) return;

    setState(() {
      _procesando = true;
      _mensajeProcesando = 'Buscando tus productos en la tienda…';
    });
    await _tts.speak(_mensajeProcesando);

    try {
      final resultado = await _productService.procesarListaVoz(_textoDetectado);

      if (!mounted) return;
      setState(() => _procesando = false);

      if (resultado.productosEncontrados.isEmpty) {
        await _tts.speak(
          'No he encontrado ningún producto. Por favor, vuelve a dictar tu lista.',
        );
        return;
      }

      await _tts.speak(resultado.mensajeVoz);

      // Navegar a la pantalla de escaneo con datos enriquecidos
      Navigator.pushNamed(
        context,
        '/scan',
        arguments: {
          'productos': resultado.productosEncontrados.map((p) => p.nombre).toList(),
          'productosDetalle': resultado.productosEncontrados,
        },
      );
    } catch (e) {
      setState(() {
        _procesando = false;
        _mensajeProcesando = '';
      });
      await _tts.speak('Ha habido un error al procesar tu lista. Inténtalo de nuevo.');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    _voiceService.parar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: Column(
          children: [

            // ── BARRA SUPERIOR ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Volver a la pantalla de inicio',
                    child: IconButton(
                      onPressed: () {
                        _tts.stop();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 30,
                      color: _verde,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Tu lista de la compra',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _verde,
                      ),
                    ),
                  ),
                  // Botón repetir instrucciones
                  Semantics(
                    button: true,
                    label: 'Repetir instrucciones',
                    child: IconButton(
                      onPressed: _anunciarPantalla,
                      icon: const Icon(Icons.volume_up, size: 28),
                      color: _verde,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── ESTADO ACTUAL ───────────────────────────────────────────────
            Semantics(
              liveRegion: true,
              label: _escuchando ? 'Escuchando tu voz' : 'Esperando tu lista',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _escuchando
                      ? _rojo.withOpacity(0.1)
                      : _verde.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _escuchando ? _rojo : _verde,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _escuchando ? Icons.mic : Icons.mic_none,
                      color: _escuchando ? _rojo : _verde,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _escuchando ? 'Escuchando...' : 'Di tu lista de la compra',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: _escuchando ? _rojo : _verde,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── TEXTO DETECTADO ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Semantics(
                liveRegion: true,
                label: _textoDetectado.isEmpty
                    ? 'Di algo como: quiero leche, tomate y pan'
                    : 'Has dicho: $_textoDetectado',
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 90),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8F4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _verde.withOpacity(0.35),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _textoDetectado.isEmpty
                        ? 'Di algo como:\n"quiero leche, tomate y pan"'
                        : '"$_textoDetectado"',
                    style: TextStyle(
                      fontSize: 21,
                      color: _textoDetectado.isEmpty ? _gris : _texto,
                      fontStyle: _textoDetectado.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── BOTÓN MICRÓFONO GRANDE ──────────────────────────────────────
            ScaleTransition(
              scale: _escuchando ? _animScale : const AlwaysStoppedAnimation(1.0),
              child: Semantics(
                button: true,
                label: _escuchando
                    ? 'Botón parar escucha. Pulsa para parar de escuchar'
                    : 'Botón micrófono. Pulsa para empezar a dictar',
                child: GestureDetector(
                  onTap: _escuchando ? _parar : _iniciarEscucha,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _escuchando ? _rojo : _verde,
                      shape: BoxShape.circle,
                      border: Border.all(color: _amarillo, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: (_escuchando ? _rojo : _verde).withOpacity(0.4),
                          blurRadius: 44,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _escuchando ? Icons.stop_rounded : Icons.mic,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              _escuchando ? 'PULSA PARA PARAR' : 'PULSA PARA HABLAR',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _escuchando ? _rojo : _verde,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // ── INDICADOR DE CARGA ──────────────────────────────────────────
            if (_procesando)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: _verde,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _mensajeProcesando,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: _verde,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ── BOTÓN CONFIRMAR ─────────────────────────────────────────────
            if (!_escuchando && !_procesando && _textoDetectado.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Semantics(
                  button: true,
                  label: 'Botón confirmar lista. Pulsa para buscar tus productos en la tienda',
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmar,
                      icon: const Icon(Icons.check_circle_outline, size: 28),
                      label: const Text(
                        'Confirmar lista',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verde,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}