import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service de notification Toast
class ToastService {
  static void show({
    required String title,
    String? message,
    ToastType type = ToastType.info,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message ?? '',
      snackPosition: position,
      backgroundColor: _getBackgroundColor(type),
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCirc,
      animationDuration: const Duration(milliseconds: 400),
      icon: _getIcon(type),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static void success(String title, {String? message}) {
    show(title: title, message: message, type: ToastType.success);
  }

  static void error(String title, {String? message}) {
    show(title: title, message: message, type: ToastType.error);
  }

  static void warning(String title, {String? message}) {
    show(title: title, message: message, type: ToastType.warning);
  }

  static void info(String title, {String? message}) {
    show(title: title, message: message, type: ToastType.info);
  }

  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFF44336);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  static Icon _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: 28,
        );
      case ToastType.error:
        return const Icon(Icons.error_outline, color: Colors.white, size: 28);
      case ToastType.warning:
        return const Icon(
          Icons.warning_amber_outlined,
          color: Colors.white,
          size: 28,
        );
      case ToastType.info:
        return const Icon(Icons.info_outline, color: Colors.white, size: 28);
    }
  }
}

enum ToastType { success, error, warning, info }

// Raccourcis globaux pour compatibilité avec le code existant
void showToast({required String title, String? description}) {
  ToastService.info(title, message: description);
}

void showSuccessToast(String title, {String? description}) {
  ToastService.success(title, message: description);
}

void showErrorToast(String title, {String? description}) {
  ToastService.error(title, message: description);
}

void showWarningToast(String title, {String? description}) {
  ToastService.warning(title, message: description);
}

void showInfoToast(String title, {String? description}) {
  ToastService.info(title, message: description);
}
