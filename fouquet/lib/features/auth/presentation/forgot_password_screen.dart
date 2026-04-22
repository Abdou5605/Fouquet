import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/features/auth/controllers/forgot_password_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.find();

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
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildLabel('Adresse email'),
                const SizedBox(height: 8),
                _buildEmailField(controller),
                const SizedBox(height: 36),
                _buildSubmitBtn(controller),
                const SizedBox(height: 24),
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            CupertinoIcons.lock_open,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mot de passe oublié ? 🔑',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Entrez votre email et nous vous enverrons un code pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildEmailField(ForgotPasswordController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateEmail,
      decoration: InputDecoration(
        hintText: 'exemple@email.com',
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        prefixIcon: Icon(
          CupertinoIcons.mail,
          color: AppColors.primary,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
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
  }

  Widget _buildSubmitBtn(ForgotPasswordController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value ? null : controller.sendResetCode,
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
                : const Text(
                    'Envoyer le code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous vous souvenez ? ',
          style: TextStyle(fontSize: 13, color: AppColors.textGray),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Se connecter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
