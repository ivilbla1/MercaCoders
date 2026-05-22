import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/edge_impulse_service.dart';

const _verde = Color(0xFF2E7D32);

// Umbrales de la lógica de auto-captura
const double _confidenceThreshold = 0.80;   // Confianza mínima para aceptar
const int _consensusCount = 2;              // Predicciones iguales seguidas necesarias
const int _maxAttempts = 15;                // Intentos antes de pedir reposicionar
const Duration _captureInterval = Duration(milliseconds: 700);
const Duration _resetDelay = Duration(seconds: 4); // Damos 4 segundos para que escuchen bien antes de reiniciar

class CameraRecognitionScreen extends StatefulWidget {
  const CameraRecognitionScreen({super.key});

  @override
  State<CameraRecognitionScreen> createState() => _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState extends State<CameraRecognitionScreen> {
  CameraController? _controller;
  EdgeImpulseService? _edgeService;
  final FlutterTts _flutterTts = FlutterTts();

  bool _initialized = false;
  bool _isScanning = false;     
  bool _isProcessing = false;   
  String? _error;

  // Estado del escaneo
  String? _currentLabel;
  double? _currentConfidence;
  String? _confirmedLabel;
  double? _confirmedConfidence;
  String? _statusMessage;
  int _attempts = 0;

  final List<String> _recentLabels = [];

  Timer? _captureTimer;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    // EJECUCIÓN EN PARALELO:
    _initTtsAndGreet();         // 1. Configura la voz y saluda DE INMEDIATO
    _initializeCameraAndModel(); // 2. En segundo plano carga la cámara y el modelo
  }

  /// Inicializa el motor de voz al instante y da instrucciones al usuario invidente
  Future<void> _initTtsAndGreet() async {
    try {
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.55); // Fluido pero entendible
      await _flutterTts.setVolume(1.0);
      
      // Saludo instantáneo sin esperar a la cámara
      await _flutterTts.speak("Iniciando Merca Coders. Por favor, apunta con la cámara hacia el producto.");
    } catch (e) {
      print("Error al iniciar TTS de inmediato: $e");
    }
  }

  Future<void> _initializeCameraAndModel() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      // Estas dos líneas toman tiempo en el hardware del dispositivo
      await _controller!.initialize();
      _edgeService = await EdgeImpulseService.load();

      if (!mounted) return;
      setState(() => _initialized = true);
      
      // Avisamos de forma fluida que ya estamos escaneando de verdad
      await _flutterTts.speak("Cámara lista. Buscando producto.");
      
      _startScanning();
    } catch (e) {
      setState(() {
        _error = 'No se pudo inicializar la cámara o el modelo: $e';
      });
      await _flutterTts.speak("Error al iniciar la cámara.");
    }
  }

  void _startScanning() {
    if (!_initialized) return;
    _resetTimer?.cancel();
    setState(() {
      _isScanning = true;
      _isProcessing = false;
      _attempts = 0;
      _recentLabels.clear();
      _currentLabel = null;
      _currentConfidence = null;
      _confirmedLabel = null;
      _confirmedConfidence = null;
      _statusMessage = 'Buscando producto…';
    });
    _scheduleNextCapture(immediate: true);
  }

  void _stopScanning({String? finalStatus}) {
    _captureTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      if (finalStatus != null) _statusMessage = finalStatus;
    });
  }

  void _scheduleNextCapture({bool immediate = false}) {
    if (!_isScanning) return;
    _captureTimer?.cancel();
    _captureTimer = Timer(
      immediate ? Duration.zero : _captureInterval,
      _captureAndAnalyze,
    );
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isScanning || _isProcessing) return;
    if (_controller == null || !_controller!.value.isInitialized || _edgeService == null) {
      return;
    }

    _isProcessing = true;
    _attempts++;

    try {
      final picture = await _controller!.takePicture();
      final fileBytes = await File(picture.path).readAsBytes();
      File(picture.path).delete().ignore();

      final results = await _edgeService!.classifyImage(fileBytes);
      if (!mounted || !_isScanning) return;

      if (results.isEmpty) {
        _onAttemptFailed('Sin resultados');
        return;
      }

      final topLabel = results.first['label'] as String;
      final topConfidence = results.first['confidence'] as double;

      setState(() {
        _currentLabel = topLabel;
        _currentConfidence = topConfidence;
      });

      if (topConfidence >= _confidenceThreshold) {
        _recentLabels.add(topLabel);
        if (_recentLabels.length > _consensusCount) {
          _recentLabels.removeAt(0);
        }

        final consensusReached = _recentLabels.length >= _consensusCount &&
            _recentLabels.every((label) => label == topLabel);

        if (consensusReached) {
          _stopScanning(finalStatus: '¡Producto identificado!');
          setState(() {
            _confirmedLabel = topLabel;
            _confirmedConfidence = topConfidence;
          });

          // Locución del producto
          if (topLabel.toLowerCase() != 'unknown') {
            await _flutterTts.speak(topLabel);
          } else {
            await _flutterTts.speak("Producto desconocido, por favor reubica el objeto.");
          }

          // Espera adaptada para el usuario antes de reactivar el bucle automático
          _resetTimer = Timer(_resetDelay, () {
            if (mounted) _startScanning();
          });
          return;
        }
      } else {
        _recentLabels.clear();
      }

      _onAttemptFailed(null);
    } catch (e) {
      _onAttemptFailed('Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _onAttemptFailed(String? errorText) {
    if (!mounted || !_isScanning) return;

    if (_attempts >= _maxAttempts) {
      _stopScanning(
        finalStatus: 'Tiempo límite alcanzado. Mueve el producto.',
      );
      _flutterTts.speak("No encuentro ningún producto conocido. Por favor, muévelo un poco.");
      
      _resetTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) _startScanning();
      });
      return;
    }

    setState(() {
      _statusMessage = errorText ?? 'Analizando… intento $_attempts/$_maxAttempts';
    });
    _scheduleNextCapture();
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _resetTimer?.cancel();
    _controller?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nota: Mantenemos la interfaz scannable por si un familiar o tú queréis ver qué pasa en pantalla
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _verde,
        title: const Text('MercaCoders Scanner'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF5EFE6), Color(0xFFEDE0D0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(_error!, style: const TextStyle(fontSize: 18, color: Colors.redAccent), textAlign: TextAlign.center),
                )
              else if (!_initialized)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(borderRadius: BorderRadius.circular(24), child: CameraPreview(_controller!)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (_confirmedLabel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text('¡Identificado!', style: TextStyle(fontSize: 18, color: _verde, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(_confirmedLabel!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ],
                  ),
                )
              else if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(_statusMessage!, style: const TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}