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
  dynamic _tflite;

  bool get isAvailable => _isLoaded;
  bool get isPlatformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> loadModel() async {
    if (_loadAttempted && _isLoaded) return;
    if (_loadAttempted && !_isLoaded) {
      return;
    }
    _loadAttempted = true;

    try {
      _tflite = await _loadTFLite();
      if (_tflite != null) {
        await _tflite.loadModel(
          model: 'assets/waste_classifier.tflite',
          labels: 'assets/labels.txt',
          numThreads: 1,
          isAsset: true,
        );
        _isLoaded = true;
        if (kDebugMode) debugPrint('TFLite model loaded successfully');
      }
    } catch (e) {
      _isLoaded = false;
      if (kDebugMode) debugPrint('TFLite loadModel failed: $e');
    }
  }

  Future<dynamic> _loadTFLite() async {
    try {
      dynamic tflite;
      await () async {
        tflite = await _dynamicImport();
      }();
      return tflite;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load TFLite: $e');
      return null;
    }
  }

  Future<dynamic> _dynamicImport() async {
    return null;
  }

  Future<TFLiteResult?> classify(Uint8List imageBytes) async {
    if (!_isLoaded || _tflite == null) {
      if (kDebugMode) debugPrint('TFLite not loaded, returning null');
      return null;
    }

    try {
      final resizedBytes = await _preprocessImage(imageBytes);
      if (resizedBytes == null) return null;

      final results = await _tflite.runModelOnBinary(binary: resizedBytes);
      if (results == null || results.isEmpty) return null;

      final result = results.first;
      final label = result['label'] as String?;
      final confidence = (result['confidence'] as num?)?.toDouble();

      if (label == null || confidence == null) return null;

      return TFLiteResult(
        category: label,
        confidence: confidence,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('TFLite classify failed: $e');
      return null;
    }
  }

  Future<Uint8List?> _preprocessImage(Uint8List imageBytes) async {
    return imageBytes;
  }

  void dispose() {
    _isLoaded = false;
    _loadAttempted = false;
    _tflite = null;
  }
}
