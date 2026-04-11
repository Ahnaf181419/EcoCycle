import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/storage_service.dart';
import '../data/services/tflite_service.dart';
import '../data/services/supabase_function_service.dart';
import '../data/repositories/submission_repository.dart';
import '../data/models/submission_model.dart';
import '../../auth/logic/auth_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final tfLiteServiceProvider = Provider<TFLiteService>((ref) {
  final service = TFLiteService();
  ref.onDispose(service.dispose);
  return service;
});

final supabaseFunctionServiceProvider = Provider<SupabaseFunctionService>((
  ref,
) {
  return SupabaseFunctionService();
});

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepository();
});

final classificationProvider =
    StateNotifierProvider<ClassificationNotifier, ClassificationState>((ref) {
  return ClassificationNotifier(
    ref: ref,
    storageService: ref.watch(storageServiceProvider),
    tfLiteService: ref.watch(tfLiteServiceProvider),
    supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
  );
});

final submissionHistoryProvider =
    StreamProvider.autoDispose<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.getSubmissionHistory();
});

final submissionDetailProvider =
    StreamProvider.autoDispose.family<Submission?, String>((
  ref,
  id,
) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.watchSubmission(id);
});

final recentSubmissionsProvider =
    StreamProvider.autoDispose<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.getRecentSubmissions();
});

class ClassificationState {
  static const _sentinel = Object();

  final bool isCapturing;
  final bool isUploading;
  final bool isClassifying;
  final String? imagePath;
  final String? imageUrl;
  final String? storagePath;
  final String? submissionId;
  final SubmissionState? submissionState;
  final String? category;
  final double? confidence;
  final int? pointsAwarded;
  final String? error;
  final Map<String, dynamic>? tfliteResult;

  const ClassificationState({
    this.isCapturing = false,
    this.isUploading = false,
    this.isClassifying = false,
    this.imagePath,
    this.imageUrl,
    this.storagePath,
    this.submissionId,
    this.submissionState,
    this.category,
    this.confidence,
    this.pointsAwarded,
    this.error,
    this.tfliteResult,
  });

  ClassificationState copyWith({
    bool? isCapturing,
    bool? isUploading,
    bool? isClassifying,
    Object? imagePath = _sentinel,
    Object? imageUrl = _sentinel,
    Object? storagePath = _sentinel,
    Object? submissionId = _sentinel,
    Object? submissionState = _sentinel,
    Object? category = _sentinel,
    Object? confidence = _sentinel,
    Object? pointsAwarded = _sentinel,
    Object? error = _sentinel,
    Object? tfliteResult = _sentinel,
  }) {
    return ClassificationState(
      isCapturing: isCapturing ?? this.isCapturing,
      isUploading: isUploading ?? this.isUploading,
      isClassifying: isClassifying ?? this.isClassifying,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      storagePath:
          storagePath == _sentinel ? this.storagePath : storagePath as String?,
      submissionId: submissionId == _sentinel
          ? this.submissionId
          : submissionId as String?,
      submissionState: submissionState == _sentinel
          ? this.submissionState
          : submissionState as SubmissionState?,
      category: category == _sentinel ? this.category : category as String?,
      confidence:
          confidence == _sentinel ? this.confidence : confidence as double?,
      pointsAwarded: pointsAwarded == _sentinel
          ? this.pointsAwarded
          : pointsAwarded as int?,
      error: error == _sentinel ? this.error : error as String?,
      tfliteResult: tfliteResult == _sentinel
          ? this.tfliteResult
          : tfliteResult as Map<String, dynamic>?,
    );
  }

  bool get isProcessing => isCapturing || isUploading || isClassifying;
}

class ClassificationNotifier extends StateNotifier<ClassificationState> {
  final Ref _ref;
  final StorageService _storageService;
  final TFLiteService _tfLiteService;
  final SupabaseFunctionService _supabaseFunctionService;
  final _uuid = const Uuid();

  ClassificationNotifier({
    required Ref ref,
    required StorageService storageService,
    required TFLiteService tfLiteService,
    required SupabaseFunctionService supabaseFunctionService,
  })  : _ref = ref,
        _storageService = storageService,
        _tfLiteService = tfLiteService,
        _supabaseFunctionService = supabaseFunctionService,
        super(const ClassificationState()) {
    _initTFLite();
  }

  Future<void> _initTFLite() async {
    try {
      await _tfLiteService.loadModel();
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load TFLite model: $e');
    }
  }

  Future<void> captureImage(ImageSource source) async {
    state = state.copyWith(isCapturing: true, error: null);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        state = state.copyWith(isCapturing: false);
        return;
      }

      state = state.copyWith(isCapturing: false, imagePath: pickedFile.path);
    } catch (e) {
      state = state.copyWith(isCapturing: false, error: e.toString());
    }
  }

  Future<void> classifyImage() async {
    if (state.isProcessing) return;

    final imagePath = state.imagePath;
    if (imagePath == null) return;

    final user = _ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(error: 'You must be signed in to classify.');
      return;
    }

    // The OS can evict an ImagePicker temp file if the app was backgrounded
    // between capture and classify. Fail loudly with an actionable message
    // instead of exploding inside StorageService.
    final file = File(imagePath);
    if (!await file.exists()) {
      state = state.copyWith(
        isCapturing: false,
        isUploading: false,
        isClassifying: false,
        error: 'Captured image is no longer available. Please retake it.',
      );
      return;
    }

    state = state.copyWith(isUploading: true, error: null);

    try {
      final idempotencyKey = _uuid.v4();
      final fileName = 'waste_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final (:imageUrl, :storagePath) = await _storageService.uploadImage(
        userId: user.uid,
        filePath: imagePath,
        fileName: fileName,
      );
      if (!mounted) return;

      Map<String, dynamic>? tfliteResult;
      if (_tfLiteService.isAvailable) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        final result = await _tfLiteService.classify(bytes);
        if (!mounted) return;
        if (result != null) {
          tfliteResult = {
            'category': result.category,
            'confidence': result.confidence,
          };
        }
      }

      state = state.copyWith(
        isUploading: false,
        isClassifying: true,
        imageUrl: imageUrl,
        storagePath: storagePath,
        tfliteResult: tfliteResult,
      );

      final result = await _supabaseFunctionService.classifySubmission(
        imageUrl: imageUrl,
        storagePath: storagePath,
        idempotencyKey: idempotencyKey,
        userId: user.uid,
        username: user.username ?? 'anonymous',
        tfliteResult: tfliteResult,
      );
      if (!mounted) return;

      final submissionStateStr = result['state'] as String? ?? 'SUBMITTED';
      final submissionState = _parseSubmissionState(submissionStateStr);

      state = state.copyWith(
        isClassifying: false,
        submissionId: result['submissionId'] as String?,
        submissionState: submissionState,
        category: result['category'] as String?,
        confidence: (result['confidence'] as num?)?.toDouble(),
        pointsAwarded: result['pointsAwarded'] as int?,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isUploading: false,
        isClassifying: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const ClassificationState();
  }

  SubmissionState _parseSubmissionState(String stateStr) {
    switch (stateStr) {
      case 'SUBMITTED':
        return SubmissionState.submitted;
      case 'CLASSIFIED':
        return SubmissionState.classified;
      case 'VERIFIED':
        return SubmissionState.verified;
      case 'REWARDED':
        return SubmissionState.rewarded;
      case 'DISPUTED':
        return SubmissionState.disputed;
      case 'RESOLVED':
        return SubmissionState.resolved;
      case 'REJECTED':
        return SubmissionState.rejected;
      case 'FLAGGED_DUPLICATE':
        return SubmissionState.flaggedDuplicate;
      default:
        return SubmissionState.submitted;
    }
  }
}
