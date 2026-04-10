import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/utils/image_utils.dart';

class TFLiteResult {
  final String category;
  final double confidence;

  const TFLiteResult({required this.category, required this.confidence});
}

class TFLiteService {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  bool _loadAttempted = false;

  static const String _modelPath = 'assets/models/waste_classifier.tflite';

  static const Map<int, String> _classToCategory = {
    0: 'recyclable',
    1: 'recyclable',
    2: 'recyclable',
    3: 'recyclable',
    4: 'recyclable',
    5: 'organic',
  };

  bool get isAvailable => _isLoaded;
  bool get isPlatformSupported => !kIsWeb && Platform.isAndroid;

  Future<void> loadModel() async {
    if (_loadAttempted) return;
    _loadAttempted = true;

    if (!isPlatformSupported) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
    }
  }

  Future<TFLiteResult?> classify(Uint8List imageBytes) async {
    if (!_isLoaded || _interpreter == null) return null;

    try {
      final preprocessed = ImageUtils.preprocessForTFLite(imageBytes);
      final input = _bytesToFloat32List(preprocessed);

      final output = List.filled(1, List.filled(6, 0.0));
      _interpreter!.run(input, output);

      final probabilities = output[0];
      double maxProb = 0;
      int maxIndex = 0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final category = _classToCategory[maxIndex] ?? 'recyclable';

      return TFLiteResult(category: category, confidence: maxProb);
    } catch (e) {
      return null;
    }
  }

  List<List<List<List<double>>>> _bytesToFloat32List(List<int> bytes) {
    final image = _decodeImage(bytes);
    final height = 224;
    final width = 224;

    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final pixelIndex = (y * width + x) * 3;
          if (pixelIndex + 2 < image.length) {
            return [
              image[pixelIndex] / 255.0,
              image[pixelIndex + 1] / 255.0,
              image[pixelIndex + 2] / 255.0,
            ];
          }
          return [0.0, 0.0, 0.0];
        }),
      ),
    );

    return input;
  }

  List<int> _decodeImage(List<int> bytes) {
    return bytes;
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }
}
