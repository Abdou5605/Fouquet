import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:get/get.dart';
import '../service/auth_api_service.dart';

class RegisterController extends GetxController {
  // ─── Controllers des champs ───────────────────────────
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── États ────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmHidden = true.obs;

  // ─── Toggles ──────────────────────────────────────────
  void togglePassword() => isPasswordHidden.toggle();
  void toggleConfirmPassword() => isConfirmHidden.toggle();

  // ─── Nettoyage numéro ─────────────────────────────────
  String _cleanPhone(String value) {
    String phone = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (phone.startsWith('229')) phone = phone.substring(3);
    return phone;
  }

  // ─── Validation ───────────────────────────────────────
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Prénom requis';
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nom requis';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    if (!GetUtils.isEmail(value.trim())) return 'Email invalide';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Numéro requis';
    final phone = _cleanPhone(value);
    if (!RegExp(r'^\d+$').hasMatch(phone)) return 'Chiffres uniquement';
    if (phone.length != 10) return 'Le numéro doit contenir 10 chiffres';
    if (!phone.startsWith('01')) return 'Le numéro doit commencer par 01';
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Adresse requise';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Confirmation requise';
    if (value != passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // ─── Register ─────────────────────────────────────────
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final success = await AuthApiService.register(
      firstname: firstNameController.text.trim(),
      lastname: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone: _cleanPhone(phoneController.text),
      address: addressController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    isLoading.value = false;

    if (success) {
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'email': emailController.text.trim(),
          'type': 'email_verification',
        },
      );
    }
  }

  // ─── Navigation login ─────────────────────────────────
  void goToLogin() => Get.back();

  // ─── Nettoyage ────────────────────────────────────────
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
