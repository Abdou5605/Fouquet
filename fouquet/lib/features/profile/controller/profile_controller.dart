import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/auth/controllers/login_controller.dart';
import 'package:fouquet/features/auth/service/auth_api_service.dart';
import 'package:fouquet/features/profile/service/profile_api_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // ─── Données utilisateur ──────────────────────────────
  final fullName = ''.obs;
  final firstname = ''.obs; // ✅ Ajouté
  final lastname = ''.obs; // ✅ Ajouté
  final email = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;
  final ordersCount = 0.obs;
  final favoritesCount = 0.obs;
  final rating = '0.0'.obs;
  final avatarUrl = RxnString(); // null si pas d'avatar

  // ─── Image locale sélectionnée ────────────────────────
  final profileImage = Rxn<File>();

  // ─── États ────────────────────────────────────────────
  final isLoading = true.obs;
  final isLoggingOut = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ─── Charger le profil ────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      final user = await ProfileApiService.getProfile();
      if (user != null) {
        firstname.value = user['first_name'] ?? '';
        lastname.value = user['last_name'] ?? '';
        fullName.value =
            user['full_name'] ?? '${firstname.value} ${lastname.value}'.trim();
        email.value = user['email'] ?? '';
        phone.value = user['phone'] ?? '';
        address.value = user['address'] ?? '';
        avatarUrl.value = user['avatar'];
        ordersCount.value = user['orders_count'] ?? 0;
        favoritesCount.value = user['favorites_count'] ?? 0;
        rating.value = (user['rating'] as num?)?.toStringAsFixed(1) ?? '0.0';
      }
    } catch (e) {
      print('fetchProfile error: $e');
    } finally {
      isLoading.value = false; // ← toujours exécuté
    }
  }

  // ─── Choisir une image ────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    final img = await _picker.pickImage(source: source, imageQuality: 80);
    if (img == null) return;

    profileImage.value = File(img.path);

    // ── Upload immédiat ───────────────────────────────
    final user = await ProfileApiService.updateAvatar(filePath: img.path);
    if (user != null) avatarUrl.value = user['avatar'];
  }

  // ─── Supprimer l'avatar ───────────────────────────────
  Future<void> removeAvatar() async {
    final user = await ProfileApiService.deleteAvatar();
    if (user != null) {
      avatarUrl.value = null;
      profileImage.value = null;
    }
  }

  // ─── Bottom sheet sélection image ────────────────────
  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Photo de profil',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _photoOption(
              context: context,
              icon: CupertinoIcons.camera,
              label: 'Prendre une photo',
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _photoOption(
              context: context,
              icon: CupertinoIcons.photo_on_rectangle,
              label: 'Choisir depuis la galerie',
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery);
              },
            ),
            if (avatarUrl.value != null || profileImage.value != null) ...[
              const SizedBox(height: 12),
              _photoOption(
                context: context,
                icon: CupertinoIcons.trash,
                label: 'Supprimer la photo',
                color: AppColors.secondary,
                onTap: () async {
                  Navigator.pop(context);
                  await removeAvatar();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photoOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog déconnexion ───────────────────────────────
  void showLogoutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.square_arrow_left,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Déconnexion',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Êtes-vous sûr de vouloir\nvous déconnecter ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.textGray,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        logout();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withOpacity(0.80),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Se déconnecter',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    isLoggingOut.value = true;
    await AuthApiService.logout();
    showSuccessToast('Déconnexion réussie', description: 'À bientôt 👋');
    await Future.delayed(const Duration(milliseconds: 800));

    // ✅ Supprime le vieux LoginController avant de naviguer
    Get.delete<LoginController>(force: true);

    Get.offAllNamed(AppRoutes.login);
    // ❌ Ne pas toucher isLoggingOut après offAllNamed
    // le controller est détruit à ce stade
  }
}
