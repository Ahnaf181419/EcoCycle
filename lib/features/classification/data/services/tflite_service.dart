import 'dart:io';
import 'package:flutter/foundation.dart';

class TFLiteResult {
  final String category;
  final double confidence;

  const TFLiteResult({required this.category, required this.confidence});
}

class TFLiteService {
  bool _isLoaded = false;
  bool _loadAttempted = false;

  bool get isAvailable => _isLoaded;
  bool get isPlatformSupported => !kIsWeb && Platform.isAndroid;

  Future<void> loadModel() async {
    if (_loadAttempted) return;
    _loadAttempted = true;
    _isLoaded = false;
  }

  Future<TFLiteResult?> classify(Uint8List imageBytes) async {
    if (!_isLoaded) return null;
    return null;
  }

  void dispose() {
    _isLoaded = false;
  }
}
