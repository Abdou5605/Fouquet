import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouquet/features/auth/controllers/register_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.find();

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
                  _buildLabel('Prénom'),
                  const SizedBox(height: 8),
                  _buildFirstNameField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Nom'),
                  const SizedBox(height: 8),
                  _buildLastNameField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildEmailField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Numéro de téléphone'),
                  const SizedBox(height: 8),
                  _buildPhoneField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Adresse'),
                  const SizedBox(height: 8),
                  _buildAddressField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Mot de passe'),
                  const SizedBox(height: 8),
                  _buildPasswordField(controller),
                  const SizedBox(height: 20),
                  _buildLabel('Confirmer le mot de passe'),
                  const SizedBox(height: 8),
                  _buildConfirmField(controller),
                  const SizedBox(height: 36),
                  _buildRegisterBtn(controller),
                  const SizedBox(height: 28),
                  _buildDivider(),
                  const SizedBox(height: 28),
                  _buildLoginLink(),
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
          'Créer un compte 🎉',
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
          'Rejoignez Fouquet et commandez en quelques clics.',
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

  Widget _buildFirstNameField(RegisterController controller) {
    return TextFormField(
      controller: controller.firstNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateFirstName,
      decoration: _inputDeco(hint: 'Abdou', icon: CupertinoIcons.person),
    );
  }

  Widget _buildLastNameField(RegisterController controller) {
    return TextFormField(
      controller: controller.lastNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateLastName,
      decoration: _inputDeco(hint: 'ABLADON', icon: CupertinoIcons.person),
    );
  }

  Widget _buildEmailField(RegisterController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateEmail,
      decoration: _inputDeco(
        hint: 'exemple@email.com',
        icon: CupertinoIcons.mail,
      ),
    );
  }

  Widget _buildPhoneField(RegisterController controller) {
    return TextFormField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validatePhone,
      decoration: _inputDeco(
        hint: '01 00 00 00 00',
        icon: CupertinoIcons.phone,
      ),
    );
  }

  Widget _buildAddressField(RegisterController controller) {
    return TextFormField(
      controller: controller.addressController,
      keyboardType: TextInputType.streetAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: controller.validateAddress,
      decoration: _inputDeco(
        hint: 'Rue, Quartier, Ville',
        icon: CupertinoIcons.location,
      ),
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        validator: controller.validatePassword,
        decoration: _inputDeco(
          hint: '••••••••',
          icon: CupertinoIcons.lock,
          suffix: GestureDetector(
            onTap: controller.togglePassword,
            child: Icon(
              controller.isPasswordHidden.value
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              color: AppColors.textGray,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmField(RegisterController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.confirmPasswordController,
        obscureText: controller.isConfirmHidden.value,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        validator: controller.validateConfirmPassword,
        decoration: _inputDeco(
          hint: '••••••••',
          icon: CupertinoIcons.lock,
          suffix: GestureDetector(
            onTap: controller.toggleConfirmPassword,
            child: Icon(
              controller.isConfirmHidden.value
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye,
              color: AppColors.textGray,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterBtn(RegisterController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value ? null : controller.register,
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
                    "S'inscrire",
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
            'Déjà un compte ?',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => Get.back(),
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
            'Se connecter',
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
