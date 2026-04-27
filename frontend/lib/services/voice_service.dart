import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;

  Future<bool> inicializar() async {
    _inicializado = await _speech.initialize(
      onError: (error) => print('Error micro: $error'),
    );
    return _inicializado;
  }

  Future<void> escuchar({required Function(String) onResultado}) async {
    if (!_inicializado) await inicializar();

    await _speech.listen(
      onResult: (resultado) {
        if (resultado.finalResult) {
          onResultado(resultado.recognizedWords);
        }
      },
      localeId: 'es_ES',
    );
  }

  Future<void> parar() async {
    await _speech.stop();
  }

  bool get estaEscuchando => _speech.isListening;
}