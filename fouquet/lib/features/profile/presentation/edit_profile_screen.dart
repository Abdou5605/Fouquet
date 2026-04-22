import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/profile/controller/edit_profile_controller.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  // ── Helper Nunito ─────────────────────────────────────
  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.0,
    double letterSpacing = 0.0,
  }) => GoogleFonts.nunito(
    fontSize:      size,
    fontWeight:    weight,
    color:         color,
    height:        height,
    letterSpacing: letterSpacing,
  );

  @override
  Widget build(BuildContext context) {
    // ✅ Controller connecté
    final EditProfileController controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      // ── Avatar depuis ProfileController ──
                      _buildAvatar(),
                      const SizedBox(height: 32),

                      _buildField(
                        label:      'Prénom',
                        controller: controller.firstnameController,
                        icon:       CupertinoIcons.person,
                        validator:  controller.validateFirstname,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label:      'Nom',
                        controller: controller.lastnameController,
                        icon:       CupertinoIcons.person,
                        validator:  controller.validateLastname,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label:        'Email',
                        controller:   controller.emailController,
                        icon:         CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator:    controller.validateEmail,
                        // ✅ Email non modifiable (lecture seule)
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label:        'Téléphone',
                        controller:   controller.phoneController,
                        icon:         CupertinoIcons.phone,
                        keyboardType: TextInputType.phone,
                        validator:    controller.validatePhone,
                        // ✅ Téléphone non modifiable
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label:      'Adresse',
                        controller: controller.addressController,
                        icon:       CupertinoIcons.location,
                        validator:  controller.validateAddress,
                      ),
                      const SizedBox(height: 32),
                      Obx(() => _buildSaveBtn(controller)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:        AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:     Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset:    const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.arrow_left,
                color: AppColors.textDark,
                size:  18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Modifier le profil',
              textAlign: TextAlign.center,
              style: _nunito(
                size:   20,
                weight: FontWeight.w800,
                color:  AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ── Avatar depuis ProfileController ───────────────────
  Widget _buildAvatar() {
    final profile = Get.find<ProfileController>();
    return Obx(() {
      Widget avatarChild;
      if (profile.profileImage.value != null) {
        avatarChild = Image.file(
          profile.profileImage.value!,
          fit: BoxFit.cover,
        );
      } else if (profile.avatarUrl.value != null) {
        avatarChild = Image.network(
          profile.avatarUrl.value!,
          fit:          BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } else {
        avatarChild = _placeholder();
      }

      return Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          shape:  BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        child: ClipOval(child: avatarChild),
      );
    });
  }

  Widget _placeholder() => Container(
    color: AppColors.bgLight,
    child: const Icon(CupertinoIcons.person, size: 50, color: AppColors.textGray),
  );

  // ── Champ formulaire ──────────────────────────────────
  Widget _buildField({
    required String                  label,
    required TextEditingController   controller,
    required IconData                icon,
    TextInputType                    keyboardType = TextInputType.text,
    String? Function(String?)?       validator,
    bool                             readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _nunito(size: 13, weight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:   controller,
          keyboardType: keyboardType,
          validator:    validator,
          readOnly:     readOnly,
          style: _nunito(
            size:   14,
            weight: FontWeight.w600,
            color:  readOnly ? AppColors.textGray : AppColors.textDark,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            // ✅ Indicateur visuel si lecture seule
            suffixIcon: readOnly
                ? Icon(CupertinoIcons.lock_fill, color: AppColors.textGray, size: 16)
                : null,
            filled:     true,
            fillColor:  readOnly
                ? AppColors.divider.withOpacity(0.3)
                : AppColors.bgCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide(
                color: readOnly ? AppColors.divider : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:   BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bouton enregistrer ────────────────────────────────
  Widget _buildSaveBtn(EditProfileController controller) {
    return GestureDetector(
      onTap: controller.isLoading.value ? null : controller.saveProfile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:    double.infinity,
        height:   54,
        decoration: BoxDecoration(
          color: controller.isLoading.value
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color:     AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset:    const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color:       Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Enregistrer',
                  style: _nunito(
                    size:   16,
                    weight: FontWeight.w800,
                    color:  Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}