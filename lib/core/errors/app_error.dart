abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({required this.message, this.code, this.originalError});

  @override
  String toString() => 'AppError($code): $message';
}

class AuthError extends AppError {
  const AuthError({required super.message, super.code, super.originalError});

  factory AuthError.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthError(message: 'No user found with this email.');
      case 'wrong-password':
        return const AuthError(message: 'Incorrect password.');
      case 'email-already-in-use':
        return const AuthError(message: 'This email is already registered.');
      case 'weak-password':
        return const AuthError(
          message: 'Password is too weak. Use at least 6 characters.',
        );
      case 'invalid-email':
        return const AuthError(message: 'Invalid email address.');
      case 'user-disabled':
        return const AuthError(message: 'This account has been disabled.');
      case 'too-many-requests':
        return const AuthError(
          message: 'Too many attempts. Please try again later.',
        );
      case 'network-request-failed':
        return const AuthError(
          message: 'Network error. Check your connection.',
        );
      default:
        return AuthError(message: 'Authentication failed.', code: code);
    }
  }
}

class FirestoreError extends AppError {
  const FirestoreError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class StorageError extends AppError {
  const StorageError({required super.message, super.code, super.originalError});
}

class ClassificationError extends AppError {
  const ClassificationError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class RewardError extends AppError {
  const RewardError({required super.message, super.code, super.originalError});
}

class PermissionError extends AppError {
  const PermissionError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class NetworkError extends AppError {
  const NetworkError({required super.message, super.code, super.originalError});
}
