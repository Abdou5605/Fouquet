import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/profile/controller/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  // ── Helper Nunito ─────────────────────────────────────
  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.0,
    double letterSpacing = 0.0,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  @override
  Widget build(BuildContext context) {
    // ✅ Controller connecté
    final ChangePasswordController controller = Get.put(
      ChangePasswordController(),
    );

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 32),

              // ─── Ancien mot de passe ─────────────────
              _buildLabel('Ancien mot de passe'),
              const SizedBox(height: 8),
              Obx(
                () => _buildField(
                  ctrl: controller.oldPasswordController,
                  hint: '••••••••',
                  obscure: controller.isObscureOld.value,
                  onToggle: controller.toggleOld,
                  validator: controller.validateOldPassword,
                ),
              ),
              const SizedBox(height: 20),

              // ─── Nouveau mot de passe ────────────────
              _buildLabel('Nouveau mot de passe'),
              const SizedBox(height: 8),
              Obx(
                () => _buildField(
                  ctrl: controller.newPasswordController,
                  hint: '••••••••',
                  obscure: controller.isObscureNew.value,
                  onToggle: controller.toggleNew,
                  validator: controller.validateNewPassword,
                  onChanged: controller.onNewPasswordChanged,
                ),
              ),
              const SizedBox(height: 8),

              // ─── Indicateur de force ─────────────────
              Obx(
                () => _buildPasswordStrength(
                  controller.newPassword.value,
                  controller.passwordStrength,
                ),
              ),
              const SizedBox(height: 20),

              // ─── Confirmer le mot de passe ───────────
              _buildLabel('Confirmer le mot de passe'),
              const SizedBox(height: 8),
              Obx(
                () => _buildField(
                  ctrl: controller.confPasswordController,
                  hint: '••••••••',
                  obscure: controller.isObscureConf.value,
                  onToggle: controller.toggleConf,
                  validator: controller.validateConfPassword,
                ),
              ),
              const SizedBox(height: 40),

              // ─── Bouton ──────────────────────────────
              Obx(() => _buildSubmitBtn(controller)),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.bgLight,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Icon(
          CupertinoIcons.arrow_left,
          color: AppColors.textDark,
          size: 18,
        ),
      ),
    ),
    title: Text(
      'Mot de passe',
      style: _nunito(
        size: 18,
        weight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  // ── Bannière ──────────────────────────────────────────
  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(CupertinoIcons.shield, color: AppColors.primary, size: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Utilisez un mot de passe fort d\'au moins 6 caractères, avec des chiffres et des symboles.',
            style: _nunito(size: 13, color: AppColors.textGray, height: 1.5),
          ),
        ),
      ],
    ),
  );

  // ── Label ─────────────────────────────────────────────
  Widget _buildLabel(String text) => Text(
    text,
    style: _nunito(
      size: 13,
      weight: FontWeight.w700,
      color: AppColors.textDark,
      letterSpacing: 0.2,
    ),
  );

  // ── Champ mot de passe ────────────────────────────────
  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) => TextFormField(
    controller: ctrl,
    obscureText: obscure,
    onChanged: onChanged,
    style: _nunito(size: 14, color: AppColors.textDark),
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: _nunito(size: 14, color: AppColors.textGray),
      prefixIcon: Icon(CupertinoIcons.lock, color: AppColors.primary, size: 20),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.textGray,
            size: 20,
          ),
        ),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.secondary, width: 2),
      ),
    ),
  );

  // ── Indicateur de force ───────────────────────────────
  Widget _buildPasswordStrength(String pwd, int strength) {
    final labels = ['', 'Faible', 'Moyen', 'Fort', 'Très fort'];
    final colors = [
      AppColors.divider,
      Colors.red,
      Colors.orange,
      Colors.lightGreen,
      Colors.green,
    ];
    if (pwd.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        ...List.generate(
          4,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? colors[strength] : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          labels[strength],
          style: _nunito(
            size: 12,
            weight: FontWeight.w600,
            color: colors[strength],
          ),
        ),
      ],
    );
  }

  // ── Bouton enregistrer ────────────────────────────────
  Widget _buildSubmitBtn(ChangePasswordController controller) =>
      GestureDetector(
        onTap: controller.isLoading.value ? null : controller.changePassword,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: controller.isLoading.value
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: controller.isLoading.value
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Enregistrer',
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      );
}
