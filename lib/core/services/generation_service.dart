import 'dart:typed_data';
import 'package:dio/dio.dart';

class GenerationService {
  // ⚠️ LAISSE VIDE pour GitHub. Tu mettras ta clé UNIQUEMENT sur ton PC quand tu testes.
  static const String _apiKey = ''; 
  
  // ✅ J'ai remis la vraie URL ici (ne touche pas à ça)
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

  final Dio _dio = Dio();

  Future<Uint8List?> generateImage(String prompt) async {
    if (_apiKey.isEmpty) {
      print("⚠️ ERREUR: Pas de clé API configurée (Mode Sécurité GitHub)");
      return null;
    }

    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
        data: {"inputs": "realistic sneaker photography, side view, highly detailed, 8k, $prompt"},
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        print("Erreur API Génération: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception Génération: $e");
      return null;
    }
  }
}