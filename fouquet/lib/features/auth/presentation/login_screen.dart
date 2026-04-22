import 'package:flutter/material.dart';
import 'package:fouquet/features/auth/controllers/login_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // ✅ Controller initialisé une seule fois ici
  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildEmailField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Mot de passe'),
                  const SizedBox(height: 8),
                  _buildPasswordField(controller),
                  const SizedBox(height: 14),
                  _buildRememberRow(controller),
                  const SizedBox(height: 36),
                  _buildLoginBtn(controller),
                  const SizedBox(height: 28),
                  _buildDivider(),
                  const SizedBox(height: 28),
                  _buildRegisterLink(),
                ],
              ),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/logo.png',
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bon retour 👋',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Connectez-vous à votre compte pour continuer.',
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

  Widget _buildEmailField(LoginController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateEmail,
      decoration: _inputDeco(
        hint: 'exemple@email.com',
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        validator: controller.validatePassword,
        decoration: _inputDeco(
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          suffix: GestureDetector(
            onTap: controller.togglePassword,
            child: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textGray,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberRow(LoginController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.toggleRememberMe,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: controller.rememberMe.value
                          ? AppColors.primary
                          : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: controller.rememberMe.value
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Se souvenir de moi',
                  style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          // ✅ Navigue vers forgotPassword
          GestureDetector(
            onTap: controller.goToForgotPassword,
            child: Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Bouton connecté à controller.login()
  Widget _buildLoginBtn(LoginController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value ? null : controller.login,
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
                    'Se connecter',
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Nouveau sur Fouquet ?',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.register),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Center(
          child: Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
          : null,
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
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
