import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/voice_service.dart';
import '../services/product_service.dart';

const _verde = Color(0xFF2E7D32);

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
  late AnimationController _animController;
  late Animation<double> _animScale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animScale = Tween<double>(begin: 1.0, end: 1.15).animate(
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
      'Pulsa el botón grande para empezar a dictar. '
      'Di algo como: quiero leche, pan y tomates.',
    );
  }

  Future<void> _iniciarEscucha() async {
    await _tts.speak('Escuchando. Di tu lista.');
    await _voiceService.inicializar();
    _animController.repeat(reverse: true);
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
        _tts.speak('Has dicho: $texto. Pulsa Confirmar lista para continuar.');
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
    setState(() => _procesando = true);
    await _tts.speak('Buscando tus productos en la tienda.');
    final resultado = await _productService.procesarListaVoz(_textoDetectado);
    if (!mounted) return;
    setState(() => _procesando = false);
    if (resultado.productosEncontrados.isEmpty) {
      await _tts.speak('No he encontrado ningún producto. Por favor, vuelve a dictar tu lista.');
      return;
    }
    await _tts.speak(resultado.mensajeVoz);
    Navigator.pushNamed(context, '/scan', arguments: {
      'productos': resultado.productosEncontrados.map((p) => p.nombre).toList(),
      'productosDetalle': resultado.productosEncontrados,
    });
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
    final h = MediaQuery.of(context).size.height;
    final microSize = h * 0.30;

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

              // ── BARRA SUPERIOR ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () { _tts.stop(); Navigator.pop(context); },
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 36,
                      color: _verde,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tu lista de la compra',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: _verde,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _anunciarPantalla,
                      icon: const Icon(Icons.volume_up),
                      iconSize: 28,
                      color: _verde,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // ── ESTADO ─────────────────────────────────────
              Text(
                _escuchando ? 'Escuchando...' : 'Esto es lo que has dicho',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _escuchando ? Colors.redAccent : _verde,
                ),
              ),

              const SizedBox(height: 10),

              // ── RECUADRO TEXTO ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(18),
                constraints: const BoxConstraints(minHeight: 90),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _textoDetectado.isEmpty
                      ? 'Di algo como:\n"quiero leche, tomate y pan"'
                      : '"$_textoDetectado"',
                  style: TextStyle(
                    fontSize: 20,
                    color: _textoDetectado.isEmpty ? Colors.white60 : Colors.white,
                    fontStyle: _textoDetectado.isEmpty ? FontStyle.italic : FontStyle.normal,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 42),

              // ── BOTÓN MICRÓFONO ──────────────────────────────
              ScaleTransition(
                scale: _escuchando ? _animScale : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _escuchando ? _parar : _iniciarEscucha,
                  child: Container(
                    width: microSize,
                    height: microSize,
                    decoration: BoxDecoration(
                      color: _escuchando ? Colors.redAccent : _verde,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_escuchando ? Colors.redAccent : _verde).withOpacity(0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _escuchando ? Icons.stop : Icons.mic,
                      size: microSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── INDICADOR DE CARGA ───────────────────────────
              if (_procesando)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: _verde),
                      SizedBox(height: 8),
                      Text(
                        'Buscando productos...',
                        style: TextStyle(fontSize: 18, color: _verde, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              // ── BOTÓN CONFIRMAR ──────────────────────────────
              if (!_escuchando && !_procesando && _textoDetectado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verde,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar lista',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
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