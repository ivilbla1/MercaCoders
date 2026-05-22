import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
 
class EdgeImpulseService {
  static const String _modelAsset = 'assets/models/tflite_learn_978907_15.tflite';
  static const String _labelsAsset = 'assets/models/labels.txt';
 
  // Dimensiones esperadas por el modelo (160x160 RGB)
  static const int modelHeight = 160;
  static const int modelWidth = 160;
  static const int modelChannels = 3;
  static const int flatSize = modelHeight * modelWidth * modelChannels; // 76800
 
  final Interpreter _interpreter;
  final List<String> _labels;
 
  EdgeImpulseService._(this._interpreter, this._labels);
 
  static Future<EdgeImpulseService> load() async {
    try {
      print('EdgeImpulse: Cargando modelo desde $_modelAsset');
      final interpreter = await Interpreter.fromAsset(_modelAsset);
      print('EdgeImpulse: Modelo cargado exitosamente');
 
      print('EdgeImpulse: Cargando etiquetas desde $_labelsAsset');
      final rawLabels = await rootBundle.loadString(_labelsAsset);
      final labels = rawLabels
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      print('EdgeImpulse: Etiquetas cargadas: $labels');
 
      return EdgeImpulseService._(interpreter, labels);
    } catch (e) {
      print('EdgeImpulse Error: $e');
      print('EdgeImpulse StackTrace: ${StackTrace.current}');
      rethrow;
    }
  }
 
  Future<List<Map<String, Object>>> classifyImage(Uint8List imageBytes) async {
    final inputTensor = _interpreter.getInputTensors().first;
    final outputTensor = _interpreter.getOutputTensors().first;
    final inputShape = inputTensor.shape;
    final inputType = inputTensor.type;
    final outputShape = outputTensor.shape;
    final outputType = outputTensor.type;
 
    print('EdgeImpulse: Input shape: $inputShape, type: $inputType');
    print('EdgeImpulse: Output shape: $outputShape, type: $outputType');
 
    // Tu modelo Edge Impulse puede reportar el input de dos formas equivalentes:
    //   - [1, 160, 160, 3] (4D, formato imagen estándar)
    //   - [1, 76800]       (2D, aplanado)
    // Ambos contienen los mismos 76800 valores. Detectamos cuál es para reshapear bien.
    final bool isShape4D = inputShape.length == 4 &&
        inputShape[0] == 1 &&
        inputShape[1] == modelHeight &&
        inputShape[2] == modelWidth &&
        inputShape[3] == modelChannels;
 
    final bool isShape2D = inputShape.length == 2 &&
        inputShape[0] == 1 &&
        inputShape[1] == flatSize;
 
    if (!isShape4D && !isShape2D) {
      throw StateError(
          'El modelo espera entrada [1,160,160,3] o [1,$flatSize]. Shape actual: $inputShape');
    }
 
    if (outputShape.length != 2 || outputShape[0] != 1 || outputShape[1] != 5) {
      print('EdgeImpulse Warning: se esperaba salida [1,5] pero el modelo reporta $outputShape');
    }
 
    // Decodificar imagen
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw StateError('No se pudo decodificar la imagen capturada.');
    }
 
    final resized = img.copyResize(image, width: modelWidth, height: modelHeight);
 
    // Buffer plano (Int8List de 76800 valores en tu caso)
    final inputBytes = _createInputBytes(resized, inputType, inputTensor.params);
 
    // ✅ Reshape al shape EXACTO que reporta el intérprete
    final batchInput = isShape4D
        ? inputBytes.reshape([1, modelHeight, modelWidth, modelChannels])
        : inputBytes.reshape([1, flatSize]);
 
    // ✅ Output: buffer plano + reshape al shape del tensor [1, 5]
    final outputSize = outputShape.fold<int>(1, (value, dim) => value * dim);
    final outputBuffer = _createOutputBuffer(outputType, outputSize);
    final reshapedOutput = outputBuffer.reshape(outputShape);
 
    print('EdgeImpulse: Input buffer length: ${inputBytes.length}, expected: $flatSize');
    print('EdgeImpulse: Output buffer length: ${outputBuffer.length}, expected: $outputSize');
    print('EdgeImpulse: Input tensor type: $inputType, Output tensor type: $outputType');
 
    print('EdgeImpulse: Ejecutando inferencia...');
    try {
      _interpreter.run(batchInput, reshapedOutput);
      print('EdgeImpulse: Inferencia completada exitosamente');
    } catch (e) {
      print('EdgeImpulse: Error en inferencia: $e');
      rethrow;
    }
 
    // Después (bien): extraer la fila [0] del output reshapeado [1, 5] y aplanarla
    final List flatOutput = (reshapedOutput as List)[0] as List;
    final probabilities = _dequantizeOutput(flatOutput, outputType, outputTensor.params);

    print('EdgeImpulse: RAW int8 output: $outputBuffer');
    print('EdgeImpulse: Probabilidades: $probabilities');
    print('EdgeImpulse: Suma de probabilidades: ${probabilities.reduce((a,b) => a+b)}');
    
    final results = <Map<String, Object>>[];
    for (var i = 0; i < probabilities.length; i++) {
      final label = i < _labels.length ? _labels[i] : 'class_$i';
      results.add({
        'label': label,
        'confidence': probabilities[i],
      });
    }
    results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    print('EdgeImpulse: Resultados: ${results.map((r) => '${r['label']}: ${r['confidence']}').join(', ')}');
    return results;
  }
 
  /// Construye el buffer plano de entrada según el tipo del tensor,
  /// aplicando cuantización si procede.
  List _createInputBytes(img.Image image, TensorType type, QuantizationParams params) {
    final int width = image.width;
    final int height = image.height;
 
    final List<double> pixels = [];
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        pixels.add(pixel.r.toDouble());
        pixels.add(pixel.g.toDouble());
        pixels.add(pixel.b.toDouble());
      }
    }
 
    if (type == TensorType.float32) {
      final data = Float32List(pixels.length);
      for (int i = 0; i < pixels.length; i++) {
        data[i] = pixels[i] / 255.0;
      }
      return data;
    }
 
    if (type == TensorType.uint8) {
      final data = Uint8List(pixels.length);
      for (int i = 0; i < pixels.length; i++) {
        data[i] = _clampUint8(_quantize(pixels[i], params));
      }
      return data;
    }
 
    if (type == TensorType.int8) {
      final data = Int8List(pixels.length);
      for (int i = 0; i < pixels.length; i++) {
        data[i] = _clampInt8(_quantize(pixels[i], params));
      }
      return data;
    }
 
    throw StateError('Tipo de tensor de entrada no soportado: $type');
  }
 
  /// Crea el buffer plano de salida según el tipo del tensor.
  List _createOutputBuffer(TensorType type, int length) {
    if (type == TensorType.float32) {
      return Float32List(length);
    }
    if (type == TensorType.uint8) {
      return Uint8List(length);
    }
    if (type == TensorType.int8) {
      return Int8List(length);
    }
    throw StateError('Tipo de tensor de salida no soportado: $type');
  }
 
  /// Convierte el buffer cuantizado de salida a probabilidades [0..1].
  List<double> _dequantizeOutput(
    List buffer,
    TensorType type,
    QuantizationParams params,
  ) {
    if (type == TensorType.float32) {
      return buffer.map((value) => (value as num).toDouble()).toList();
    }
    if (type == TensorType.uint8 || type == TensorType.int8) {
      return buffer
          .map(
            (value) =>
                ((value as num).toDouble() - params.zeroPoint) * params.scale,
          )
          .toList();
    }
    throw StateError('Tipo de tensor de salida no soportado: $type');
  }

  int _quantize(double value, QuantizationParams params) {
    //return (value / params.scale + params.zeroPoint).round();
    // value viene como 0..255 (píxel crudo). Normalizamos a 0..1 antes de cuantizar.
    final normalized = value / 255.0;
    return (normalized / params.scale + params.zeroPoint).round();
  }
 
  int _clampUint8(int value) => value.clamp(0, 255);
 
  int _clampInt8(int value) => value.clamp(-128, 127);
}