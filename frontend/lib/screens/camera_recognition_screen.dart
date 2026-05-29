import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/edge_impulse_service.dart';
import 'package:image/image.dart' as img;

const _verde = Color(0xFF2E7D32);

// Umbrales de la lógica de auto-captura
const double _confidenceThreshold = 0.80;
const int _consensusCount = 2;
const int _maxAttempts = 15;
const Duration _captureInterval = Duration(milliseconds: 700);
const Duration _resetDelay = Duration(seconds: 4);

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
    _initTtsAndGreet();
    _initializeCameraAndModel();
  }

  Future<void> _initTtsAndGreet() async {
    try {
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.55);
      await _flutterTts.setVolume(1.0);
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

      await _controller!.initialize();
      _edgeService = await EdgeImpulseService.load();

      if (!mounted) return;
      setState(() => _initialized = true);
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
    if (_controller == null || !_controller!.value.isInitialized || _edgeService == null) return;
    _isProcessing = true;
    _attempts++;
    try {
      final picture = await _controller!.takePicture();
      final fileBytes = await File(picture.path).readAsBytes();
      File(picture.path).delete().ignore();
      // --- AQUÍ EMPIEZA LA MAGIA DEL RECORTADO ---
      img.Image? originalImage = img.decodeImage(fileBytes);
      
      if (originalImage == null) {
        _onAttemptFailed('Error al decodificar imagen');
        return;
      }
      // Calculamos el centro para hacer un recorte cuadrado
      int size = originalImage.width < originalImage.height ? originalImage.width : originalImage.height;
      int x = (originalImage.width - size) ~/ 2;
      int y = (originalImage.height - size) ~/ 2;
      
      // Recortamos y redimensionamos a 160x160 (lo que espera Edge Impulse)
      img.Image cropped = img.copyCrop(originalImage, x: x, y: y, width: size, height: size);
      img.Image resized = img.copyResize(cropped, width: 160, height: 160);
      
      // Convertimos de nuevo a bytes
      final processedBytes = img.encodeJpg(resized);
      
      // Llamamos al modelo con la imagen ya preparada
      final results = await _edgeService!.classifyImage(processedBytes);
      // --- FIN DE LA MAGIA ---
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
          if (topLabel.toLowerCase() != 'unknown') {
            await _flutterTts.speak(topLabel);
          } else {
            await _flutterTts.speak("Producto desconocido, por favor reubica el objeto.");
          }
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
      _stopScanning(finalStatus: 'Tiempo límite alcanzado. Mueve el producto.');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 36, 8, 0),
            child: AppBar(
              backgroundColor: _verde,
              foregroundColor: Colors.white,
              elevation: 2,
              toolbarHeight: 64,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text(
                'MercaCoders Scanner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(_error!, style: const TextStyle(fontSize: 20, color: Colors.redAccent), textAlign: TextAlign.center),
                  ),
                ),
              )
            else if (!_initialized)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _verde, strokeWidth: 4),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _verde, width: 5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _confirmedLabel != null
                    ? Column(
                        children: [
                          const Text(
                            '¡Identificado!',
                            style: TextStyle(fontSize: 20, color: Colors.white70, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _confirmedLabel!,
                            style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Text(
                        _statusMessage ?? 'Esperando…',
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}