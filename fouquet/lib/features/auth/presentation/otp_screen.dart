import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouquet/features/auth/controllers/otp_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(controller.email),
              const SizedBox(height: 32),

              // ─── Timer ──────────────────────────────
              _buildTimer(controller),
              const SizedBox(height: 32),

              // ─── Champs OTP ─────────────────────────
              _buildOtpFields(controller),
              const SizedBox(height: 36),

              // ─── Bouton Vérifier ────────────────────
              _buildVerifyBtn(controller),
              const SizedBox(height: 24),

              // ─── Renvoyer ───────────────────────────
              _buildResendRow(controller),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────
  Widget _buildHeader(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Vérification email 📩',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Un code a été envoyé à\n'),
              TextSpan(
                text: email,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Timer ────────────────────────────────────────────
  Widget _buildTimer(OtpController controller) {
    return Obx(() {
      final expired = controller.isExpired.value;
      return Column(
        children: [
          // ── Cercle timer ──────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: expired ? AppColors.secondary : AppColors.primary,
                width: 3,
              ),
              color: expired
                  ? AppColors.secondary.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.08),
            ),
            child: Center(
              child: Text(
                controller.timerText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: expired ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── Message ───────────────────────────────
          Text(
            expired
                ? 'Code expiré — demandez un nouveau code'
                : 'Le code expire dans',
            style: TextStyle(
              fontSize: 13,
              color: expired ? AppColors.secondary : AppColors.textGray,
              fontWeight: expired ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      );
    });
  }

  // ─── 6 champs OTP ─────────────────────────────────────
  Widget _buildOtpFields(OtpController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _buildOtpBox(controller, i)),
    ));
  }

  Widget _buildOtpBox(OtpController controller, int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller.controllers[index],
        focusNode: controller.focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        // ✅ Désactiver les champs si expiré
        enabled: !controller.isExpired.value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.isExpired.value
              ? AppColors.divider.withOpacity(0.3)
              : AppColors.bgCard,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.divider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: AppColors.secondary.withOpacity(0.3), width: 1.5),
          ),
        ),
        onChanged: (value) => controller.onOtpChanged(value, index),
      ),
    );
  }

  // ─── Bouton Vérifier ──────────────────────────────────
  Widget _buildVerifyBtn(OtpController controller) {
    return Obx(() => GestureDetector(
      onTap: (controller.isLoading.value || controller.isExpired.value)
          ? null
          : controller.verifyOtp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: controller.isExpired.value
              ? AppColors.divider
              : controller.isLoading.value
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: (controller.isLoading.value || controller.isExpired.value)
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
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
                  controller.isExpired.value ? 'Code expiré' : 'Vérifier',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    ));
  }

  // ─── Ligne Renvoyer ───────────────────────────────────
  Widget _buildResendRow(OtpController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous n\'avez pas reçu le code ? ',
          style: TextStyle(fontSize: 13, color: AppColors.textGray),
        ),
        GestureDetector(
          onTap: controller.isResending.value ? null : controller.resendOtp,
          child: controller.isResending.value
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Renvoyer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ],
    ));
  }
}