import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:get/get.dart';
import '../service/auth_api_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // ─── États ────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final rememberMe = false.obs;

  // ─── Toggles ──────────────────────────────────────────
  void togglePassword() => isPasswordHidden.toggle();
  void toggleRememberMe() => rememberMe.toggle();

  // ─── Validation ───────────────────────────────────────
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    if (!GetUtils.isEmail(value.trim())) return 'Email invalide';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  // ─── Login ────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final success = await AuthApiService.login(
      email: email.trim(),
      password: password,
    );

    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);
  void goToRegister() => Get.toNamed(AppRoutes.register);

  // Plus besoin de dispose() ici
}
