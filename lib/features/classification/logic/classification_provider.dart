import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/storage_service.dart';
import '../data/services/tflite_service.dart';
import '../data/services/supabase_function_service.dart';
import '../data/repositories/submission_repository.dart';
import '../data/models/submission_model.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/utils/image_utils.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final tfLiteServiceProvider = Provider<TFLiteService>((ref) {
  return TFLiteService();
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
        storageService: ref.watch(storageServiceProvider),
        tfLiteService: ref.watch(tfLiteServiceProvider),
        supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
        authState: ref.watch(authProvider),
      );
    });

final submissionHistoryProvider = StreamProvider<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.getSubmissionHistory();
});

final submissionDetailProvider = StreamProvider.family<Submission?, String>((
  ref,
  id,
) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.watchSubmission(id);
});

final recentSubmissionsProvider = StreamProvider<List<Submission>>((ref) {
  final repo = ref.watch(submissionRepositoryProvider);
  return repo.getRecentSubmissions();
});

class ClassificationState {
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
    String? imagePath,
    String? imageUrl,
    String? storagePath,
    String? submissionId,
    SubmissionState? submissionState,
    String? category,
    double? confidence,
    int? pointsAwarded,
    String? error,
    Map<String, dynamic>? tfliteResult,
  }) {
    return ClassificationState(
      isCapturing: isCapturing ?? this.isCapturing,
      isUploading: isUploading ?? this.isUploading,
      isClassifying: isClassifying ?? this.isClassifying,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      storagePath: storagePath ?? this.storagePath,
      submissionId: submissionId ?? this.submissionId,
      submissionState: submissionState ?? this.submissionState,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      error: error ?? this.error,
      tfliteResult: tfliteResult ?? this.tfliteResult,
    );
  }

  bool get isProcessing => isCapturing || isUploading || isClassifying;
}

class ClassificationNotifier extends StateNotifier<ClassificationState> {
  final StorageService _storageService;
  final TFLiteService _tfLiteService;
  final SupabaseFunctionService _supabaseFunctionService;
  final AuthState _authState;
  final _uuid = const Uuid();

  ClassificationNotifier({
    required StorageService storageService,
    required TFLiteService tfLiteService,
    required SupabaseFunctionService supabaseFunctionService,
    required AuthState authState,
  }) : _storageService = storageService,
       _tfLiteService = tfLiteService,
       _supabaseFunctionService = supabaseFunctionService,
       _authState = authState,
       super(const ClassificationState()) {
    _initTFLite();
  }

  Future<void> _initTFLite() async {
    await _tfLiteService.loadModel();
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
    if (state.imagePath == null) return;
    final user = _authState.user;
    if (user == null) return;

    state = state.copyWith(isUploading: true, error: null);

    try {
      final idempotencyKey = _uuid.v4();
      final fileName = 'waste_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final imageUrl = await _storageService.uploadImage(
        userId: user.uid,
        filePath: state.imagePath!,
        fileName: fileName,
      );

      final storagePath = ImageUtils.generateStoragePath(user.uid, fileName);

      Map<String, dynamic>? tfliteResult;
      if (_tfLiteService.isAvailable && state.imagePath != null) {
        final file = File(state.imagePath!);
        final bytes = await file.readAsBytes();
        final result = await _tfLiteService.classify(bytes);
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
        tfliteResult: tfliteResult,
      );

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
