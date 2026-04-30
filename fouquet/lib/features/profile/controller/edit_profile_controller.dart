import 'package:flutter/material.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:get/get.dart';
import 'package:fouquet/features/profile/service/profile_api_service.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';

class EditProfileController extends GetxController {
  // ─── Controllers des champs ───────────────────────────
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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

    // ✅ Si le profil est encore en chargement, on attend la fin
    if (profile.isLoading.value) {
      ever(profile.isLoading, (bool loading) {
        if (!loading) _fillControllers(profile);
      });
    } else {
      _fillControllers(profile);
    }
  }

  void _fillControllers(ProfileController profile) {
    firstnameController.text = profile.firstname.value;
    lastnameController.text = profile.lastname.value;
    emailController.text = profile.email.value;
    phoneController.text = profile.phone.value;
    addressController.text = profile.address.value;

    // ✅ Log pour voir ce qui est dans ProfileController au moment du remplissage
    print(
      '✏️ prefill → firstname: ${profile.firstname.value} | lastname: ${profile.lastname.value}',
    );
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
      lastname: lastnameController.text.trim(),
      address: addressController.text.trim(),
    );

    isLoading.value = false;

    if (user != null) {
      print('📦 updateProfile response: $user');

      final fn = firstnameController.text.trim();
      final ln = lastnameController.text.trim();

      final profile = Get.find<ProfileController>();
      // ✅ Mise à jour immédiate avec les valeurs de l'API (snake_case)
      profile.firstname.value = user['first_name'] ?? fn;
      profile.lastname.value = user['last_name'] ?? ln;
      profile.fullName.value =
          user['full_name'] ??
          '${profile.firstname.value} ${profile.lastname.value}'.trim();
      profile.email.value = user['email'] ?? profile.email.value;
      profile.phone.value = user['phone'] ?? profile.phone.value;
      profile.address.value = user['address'] ?? addressController.text.trim();

      // ✅ Force le refresh de tous les Obx qui écoutent ProfileController
      profile.update();

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
