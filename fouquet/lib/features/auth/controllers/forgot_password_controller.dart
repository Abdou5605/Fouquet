import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import '../service/auth_api_service.dart';

class ForgotPasswordController extends GetxController {
  // ─── Controller du champ ──────────────────────────────
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── États ────────────────────────────────────────────
  final isLoading = false.obs;

  // ─── Validation ───────────────────────────────────────
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    if (!GetUtils.isEmail(value.trim())) return 'Email invalide';
    return null;
  }

  // ─── Envoyer le code de réinitialisation ──────────────
  Future<void> sendResetCode() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final success = await AuthApiService.forgotPassword(
      email: emailController.text.trim(),
    );

    isLoading.value = false;

    if (success) {
      // ── Navigation vers OTP avec type reset_password ──
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'email': emailController.text.trim(),
          'type': 'password_reset',
        },
      );
    }
  }

  // ─── Nettoyage ────────────────────────────────────────
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
