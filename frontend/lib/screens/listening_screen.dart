import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../services/product_service.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  final ProductService _productService = ProductService();
  String _textoDetectado = '';
  bool _escuchando = false;
  List<String> _listaProductos = [];
  late AnimationController _animController;
  late Animation<double> _animScale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _iniciarEscucha();
  }

  Future<void> _iniciarEscucha() async {
    await _voiceService.inicializar();
    setState(() => _escuchando = true);
    await _voiceService.escuchar(
      onResultado: (texto) {
        setState(() {
          _textoDetectado = texto;
          _escuchando = false;
        });
        _animController.stop();
      },
    );
  }

  Future<void> _parar() async {
    await _voiceService.parar();
    _animController.stop();
    setState(() => _escuchando = false);
  }

  Future<void> _confirmar() async {
    if (_textoDetectado.isEmpty) return;
    final productos = await _productService.extraerProductos(_textoDetectado);
    setState(() => _listaProductos = productos);
    Navigator.pushNamed(context, '/scan', arguments: productos);
  }

  @override
  void dispose() {
    _animController.dispose();
    _voiceService.parar();
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
                      'Tu lista de la compra',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _escuchando ? 'Escuchando...' : 'Esto es lo que has dicho',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: _escuchando ? Colors.redAccent : const Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                constraints: const BoxConstraints(minHeight: 130),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _textoDetectado.isEmpty
                      ? 'Di algo como:\n"quiero leche, tomate y pan"'
                      : '"$_textoDetectado"',
                  style: TextStyle(
                    fontSize: 26,
                    color: _textoDetectado.isEmpty ? Colors.white60 : Colors.white,
                    fontStyle: _textoDetectado.isEmpty ? FontStyle.italic : FontStyle.normal,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 36),

              ScaleTransition(
                scale: _escuchando ? _animScale : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _escuchando ? _parar : _iniciarEscucha,
                  child: Container(
                    width: 280 ,
                    height: 280 ,
                    decoration: BoxDecoration(
                      color: _escuchando ? Colors.redAccent : const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_escuchando ? Colors.redAccent : const Color(0xFF2E7D32))
                              .withOpacity(0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _escuchando ? Icons.stop : Icons.mic,
                      size: 160,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              if (!_escuchando && _textoDetectado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar lista',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                      ),
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