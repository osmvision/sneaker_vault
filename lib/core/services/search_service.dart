import 'dart:typed_data';
import 'package:dio/dio.dart';

class SearchService {
  // Clé API Google Custom Search (Optionnel, sinon Fallback caméra)
  static const String _apiKey = ''; 
  static const String _cx = '';
  final Dio _dio = Dio();

  Future<Uint8List?> searchSneakerImage(String query) async {
    if (_apiKey.isEmpty) return null; 
    // ... (Logique Google API)
    return null;
  }
}