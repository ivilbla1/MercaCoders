import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/product_service.dart';

class ScanScreen extends StatefulWidget {
  final List<String> productos;
  final List<ProductoDetalle>? productosDetalle;

  const ScanScreen({
    super.key,
    required this.productos,
    this.productosDetalle,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FlutterTts _tts = FlutterTts();
  final MobileScannerController _cameraController = MobileScannerController();
  final ProductService _productService = ProductService();
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
    final detalle = widget.productosDetalle?[_productoActual];
    if (detalle != null) {
      await _tts.speak(detalle.instruccionVoz);
    } else {
      final producto = widget.productos[_productoActual];
      await _tts.speak(
        'Dirígete a buscar $producto. Cuando lo encuentres, escanealo para confirmarlo.',
      );
    }
  }

  void _onCodigoDetectado(BarcodeCapture capture) async {
    if (_productoConfirmado) return;
    final codigo = capture.barcodes.first.rawValue;
    if (codigo == null) return;

    setState(() => _productoConfirmado = true);

    final detalle = widget.productosDetalle?[_productoActual];
    if (detalle != null) {
      // TODO: llamar al backend para validar
      final resultado = await _productService.validarBarcode(
        ean: codigo,
        nombreEsperado: detalle.nombre,
      );
      await _tts.speak(resultado['mensaje_voz'] ?? 'Producto escaneado.');
    } else {
      await _tts.speak('Producto escaneado.');
    }

    Future.delayed(const Duration(seconds: 2), _siguienteProducto);
  }

  void _siguienteProducto() {
    if (_productoActual < widget.productos.length - 1) {
      setState(() {
        _productoActual++;
        _productoConfirmado = false;
      });
      _anunciarProductoActual();
    } else {
      _tts.speak('Lista completada. Dirígete a caja.');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      });
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 42,
                      color: const Color(0xFF2E7D32),
                    ),
                    const Text(
                      'Navegando',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _anunciarProductoActual,
                      icon: const Icon(Icons.volume_up),
                      iconSize: 32,
                      color: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),

              if (widget.productos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_productoActual + 1} de ${widget.productos.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.productos[_productoActual],
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.productosDetalle?[_productoActual].descripcionPasillo
                            ?? 'Pasillo pendiente de backend',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MobileScanner(
                      controller: _cameraController,
                      onDetect: _onCodigoDetectado,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _siguienteProducto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Siguiente producto',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}