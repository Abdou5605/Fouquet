import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/features/auth/service/auth_api_service.dart';
import 'package:fouquet/core/presentation/toast.dart';

class ChangePasswordController extends GetxController {
  // ─── Controllers des champs ───────────────────────────
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── États ────────────────────────────────────────────
  final isLoading = false.obs;
  final isObscureOld = true.obs;
  final isObscureNew = true.obs;
  final isObscureConf = true.obs;
  final newPassword = ''.obs;

  // ─── Toggles visibilité ───────────────────────────────
  void toggleOld() => isObscureOld.toggle();
  void toggleNew() => isObscureNew.toggle();
  void toggleConf() => isObscureConf.toggle();

  // ─── Mise à jour indicateur de force ──────────────────
  void onNewPasswordChanged(String value) => newPassword.value = value;

  // ─── Calcul de la force du mot de passe ───────────────
  int get passwordStrength {
    final pwd = newPassword.value;
    int strength = 0;
    if (pwd.length >= 6) strength++;
    if (pwd.contains(RegExp(r'[A-Z]'))) strength++;
    if (pwd.contains(RegExp(r'[0-9]'))) strength++;
    if (pwd.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
    return strength;
  }

  // ─── Validation ───────────────────────────────────────
  String? validateOldPassword(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    if (value == oldPasswordController.text) {
      return 'Doit être différent de l\'ancien';
    }
    return null;
  }

  String? validateConfPassword(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (value != newPasswordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // ─── Changer le mot de passe ──────────────────────────
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final success = await AuthApiService.changePassword(
      currentPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      newPasswordConfirmation: confPasswordController.text,
    );

    isLoading.value = false;

    if (success) {
      Get.back();
      showSuccessToast(
        'Mot de passe modifié',
        description: 'Votre mot de passe a été mis à jour avec succès.',
      );
    }
  }

  // ─── Nettoyage ────────────────────────────────────────
  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confPasswordController.dispose();
    super.onClose();
  }
}
