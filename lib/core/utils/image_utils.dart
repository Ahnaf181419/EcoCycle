import 'dart:typed_data';
import 'package:image/image.dart' as img;

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
      resized = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    final jpg = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(jpg);
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
    return 'submissions/$userId/${timestamp}_$fileName';
  }

  static double sizeInKB(Uint8List bytes) {
    return bytes.length / 1024;
  }
}
