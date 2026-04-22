import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:get/get.dart';
import '../service/auth_api_service.dart';

class OtpController extends GetxController {

  // ─── 6 controllers + focus nodes ──────────────────────
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  // ─── Arguments ────────────────────────────────────────
  late final String email;
  late final String type;

  // ─── États ────────────────────────────────────────────
  final isLoading   = false.obs;
  final isResending = false.obs;

  // ─── Timer ────────────────────────────────────────────
  static const int _totalSeconds = 5 * 60; // 5 minutes
  final secondsRemaining = _totalSeconds.obs;
  final isExpired        = false.obs;
  Timer? _timer;

  // ─── Code OTP complet ─────────────────────────────────
  String get otpCode => controllers.map((c) => c.text).join();

  // ─── Formatage du timer mm:ss ─────────────────────────
  String get timerText {
    final m = secondsRemaining.value ~/ 60;
    final s = secondsRemaining.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    email = args['email'] ?? '';
    type  = args['type']  ?? 'email_verification';
    _startTimer();
  }

  // ─── Démarrer le timer ────────────────────────────────
  void _startTimer() {
    isExpired.value        = false;
    secondsRemaining.value = _totalSeconds;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        isExpired.value = true;
        showWarningToast(
          'Code expiré',
          description: 'Votre code OTP a expiré. Veuillez en demander un nouveau.',
        );
      }
    });
  }

  // ─── Gestion saisie champ par champ ───────────────────
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    if (otpCode.length == 6) verifyOtp();
  }

  // ─── Vérifier OTP ─────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otpCode.length < 6) return;

    if (isExpired.value) {
      showWarningToast(
        'Code expiré',
        description: 'Veuillez demander un nouveau code.',
      );
      return;
    }

    isLoading.value = true;

    final success = await AuthApiService.verifyOtp(
      email: email,
      code:  otpCode,
      type:  type,
    );

    isLoading.value = false;

    if (success) {
      _timer?.cancel();
      Get.offAllNamed(AppRoutes.home);
    } else {
      _clearFields();
    }
  }

  // ─── Renvoyer OTP ─────────────────────────────────────
  Future<void> resendOtp() async {
    isResending.value = true;

    final success = await AuthApiService.resendOtp(
      email: email,
      type:  type,
    );

    isResending.value = false;

    if (success) {
      _clearFields();
      _startTimer(); // ✅ Repart le timer après renvoi
      focusNodes[0].requestFocus();
    }
  }

  // ─── Vider les champs ─────────────────────────────────
  void _clearFields() {
    for (final c in controllers) c.clear();
    focusNodes[0].requestFocus();
  }

  // ─── Nettoyage ────────────────────────────────────────
  @override
  void onClose() {
    _timer?.cancel();
    for (final c in controllers) c.dispose();
    for (final f in focusNodes)  f.dispose();
    super.onClose();
  }
}