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

  factory AuthError.fromSupabaseMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return const AuthError(message: 'Invalid email or password.');
    }
    if (lower.contains('email already registered') ||
        lower.contains('user already registered')) {
      return const AuthError(message: 'This email is already registered.');
    }
    if (lower.contains('password') && lower.contains('weak')) {
      return const AuthError(
        message: 'Password is too weak. Use at least 6 characters.',
      );
    }
    if (lower.contains('invalid email')) {
      return const AuthError(message: 'Invalid email address.');
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return const AuthError(
        message: 'Too many attempts. Please try again later.',
      );
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return const AuthError(message: 'Network error. Check your connection.');
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('not confirmed')) {
      return const AuthError(
        message: 'Please confirm your email before signing in.',
      );
    }
    if (lower.contains('not found')) {
      return const AuthError(message: 'No user found with this email.');
    }
    if (lower.contains('disabled')) {
      return const AuthError(message: 'This account has been disabled.');
    }
    return AuthError(message: 'Authentication failed.', code: message);
  }
}

class DatabaseError extends AppError {
  const DatabaseError({
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
