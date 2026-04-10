import 'package:flutter/material.dart';
import '../errors/app_error.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getUserMessage(dynamic error) {
    if (error is AppError) {
      return error.message;
    }

    if (error is Exception) {
      final message = error.toString();
      if (message.contains('SocketException') || message.contains('network')) {
        return 'Network error. Please check your connection.';
      }
      if (message.contains('timeout')) {
        return 'Request timed out. Please try again.';
      }
      return 'Something went wrong. Please try again.';
    }

    return 'An unexpected error occurred.';
  }

  static void showSnackBar(BuildContext context, dynamic error) {
    final message = getUserMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
