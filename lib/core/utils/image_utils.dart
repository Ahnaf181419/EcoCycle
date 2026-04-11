import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class _CompressParams {
  final Uint8List imageBytes;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  _CompressParams({
    required this.imageBytes,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });
}

Uint8List _compressForUploadIsolate(_CompressParams params) {
  return ImageUtils.compressForUpload(
    params.imageBytes,
    maxWidth: params.maxWidth,
    maxHeight: params.maxHeight,
    quality: params.quality,
  );
}

class ImageUtils {
  ImageUtils._();

  static Uint8List compressForUpload(
    Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 80,
  }) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    img.Image resized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      final scale = math.min(maxWidth / image.width, maxHeight / image.height);
      resized = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }

    final jpg = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(jpg);
  }

  static Future<Uint8List> compressForUploadAsync(
    Uint8List imageBytes, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 80,
  }) {
    return compute(
      _compressForUploadIsolate,
      _CompressParams(
        imageBytes: imageBytes,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      ),
    );
  }

  static Uint8List preprocessForTFLite(
    Uint8List imageBytes, {
    int targetSize = 224,
  }) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final resized = img.copyResize(
      image,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: 95));
  }

  static String generateStoragePath(String userId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitized = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return 'submissions/$userId/${timestamp}_$sanitized';
  }

  static double sizeInKB(Uint8List bytes) {
    return bytes.length / 1024;
  }
}
