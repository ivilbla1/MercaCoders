import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final List<String> productos;

  const ScanScreen({super.key, required this.productos});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FlutterTts _tts = FlutterTts();
  final MobileScannerController _cameraController = MobileScannerController();
  int _productoActual = 0;
  bool _productoConfirmado = false;

  @override
  void initState() {
    super.initState();
    _configurarTts();
    _anunciarProductoActual();
  }

  Future<void> _configurarTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  Future<void> _anunciarProductoActual() async {
    if (widget.productos.isEmpty) return;
    final producto = widget.productos[_productoActual];
    // TODO: cuando haya backend, añadir pasillo y posición
    await _tts.speak('Dirígete a buscar $producto. Cuando lo encuentres, escanealo para confirmarlo.');
  }

  void _onCodigoDetectado(BarcodeCapture capture) {
    if (_productoConfirmado) return;
    final codigo = capture.barcodes.first.rawValue;
    if (codigo == null) return;

    setState(() => _productoConfirmado = true);

    // TODO: llamar al backend con el código para validar el producto
    _tts.speak('Producto añadido correctamente. ');
    
    Future.delayed(const Duration(seconds: 2), () {
      _siguienteProducto();
    });
  }

  void _siguienteProducto() {
    if (_productoActual < widget.productos.length - 1) {
      setState(() {
        _productoActual++;
        _productoConfirmado = false;
      });
      _anunciarProductoActual();
    } else {
      _tts.speak('Lista completada. ¡Compra terminada!');
      // TODO: navegar a pantalla de resumen
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _cameraController.dispose();
    super.dispose();
  }

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

              // ── BARRA SUPERIOR ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 28,
                      color: const Color(0xFF00874A),
                    ),
                    const Text(
                      'Navegando',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00874A),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PRODUCTO ACTUAL ──────────────────────────────
              if (widget.productos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00874A).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_productoActual + 1} de ${widget.productos.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.productos[_productoActual],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00874A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // TODO: mostrar pasillo y posición del backend
                      const Text(
                        'Pasillo pendiente de backend',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // ── CÁMARA ───────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: _onCodigoDetectado,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── BOTÓN SIGUIENTE MANUAL ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _siguienteProducto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00874A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Siguiente producto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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