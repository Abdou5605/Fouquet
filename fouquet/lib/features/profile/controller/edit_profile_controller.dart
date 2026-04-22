import 'package:flutter/material.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:get/get.dart';
import 'package:fouquet/features/profile/service/profile_api_service.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';

class EditProfileController extends GetxController {

  // ─── Controllers des champs ───────────────────────────
  final firstnameController = TextEditingController();
  final lastnameController  = TextEditingController();
  final emailController     = TextEditingController();
  final phoneController     = TextEditingController();
  final addressController   = TextEditingController();
  final formKey             = GlobalKey<FormState>();

  // ─── États ────────────────────────────────────────────
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillFields();
  }

  // ─── Pré-remplissage depuis ProfileController ─────────
  void _prefillFields() {
    final profile = Get.find<ProfileController>();

    final parts = profile.fullName.value.trim().split(' ');
    firstnameController.text = parts.isNotEmpty ? parts.first : '';
    lastnameController.text  = parts.length > 1
        ? parts.sublist(1).join(' ')
        : '';

    emailController.text   = profile.email.value;
    phoneController.text   = profile.phone.value;
    addressController.text = profile.address.value;
  }

  // ─── Validation ───────────────────────────────────────
  String? validateFirstname(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  String? validateLastname(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    if (!GetUtils.isEmail(value.trim())) return 'Email invalide';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  // ─── Enregistrer le profil ────────────────────────────
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final user = await ProfileApiService.updateProfile(
      firstname: firstnameController.text.trim(),
      lastname:  lastnameController.text.trim(),
      address:   addressController.text.trim(),
    );

    isLoading.value = false;

    if (user != null) {
      // ✅ Mettre à jour le ProfileController
      final profile          = Get.find<ProfileController>();
      profile.fullName.value = user['full_name'] ?? '';
      profile.email.value    = user['email']     ?? '';
      profile.phone.value    = user['phone']      ?? '';
      profile.address.value  = user['address']    ?? '';

      // ✅ Back d'abord, toast ensuite
      Get.back();

      showSuccessToast(
        'Profil mis à jour',
        description: 'Vos informations ont été enregistrées avec succès.',
      );
    }
  }

  // ─── Nettoyage ────────────────────────────────────────
  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}