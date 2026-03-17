import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    Get.offAllNamed(AppRoutes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLabel('Nom complet'),
                  const SizedBox(height: 8),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildLabel('Numéro de téléphone'),
                  const SizedBox(height: 8),
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildLabel('Adresse'),
                  const SizedBox(height: 8),
                  _buildAddressField(),
                  const SizedBox(height: 20),
                  _buildLabel('Mot de passe'),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildLabel('Confirmer le mot de passe'),
                  const SizedBox(height: 8),
                  _buildConfirmField(),
                  const SizedBox(height: 36),
                  _buildRegisterBtn(),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Nom requis';
        if (v.trim().split(' ').length < 2) return 'Entrez prénom et nom';
        return null;
      },
      decoration: _inputDeco(
        hint: 'Jean Dupont',
        icon: CupertinoIcons.person,
      ), // ✅
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Email requis';
        if (!v.contains('@')) return 'Email invalide';
        return null;
      },
      decoration: _inputDeco(
        hint: 'exemple@email.com',
        icon: CupertinoIcons.mail,
      ), // ✅
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Numéro requis';
        if (v.length < 8) return 'Numéro invalide';
        return null;
      },
      decoration: _inputDeco(
        hint: '+229 00 00 00 00',
        icon: CupertinoIcons.phone,
      ), // ✅
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressCtrl,
      keyboardType: TextInputType.streetAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Adresse requise';
        return null;
      },
      decoration: _inputDeco(
        hint: 'Rue, Quartier, Ville',
        icon: CupertinoIcons.location,
      ), // ✅
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _obscurePass,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Mot de passe requis';
        if (v.length < 6) return 'Minimum 6 caractères';
        return null;
      },
      decoration: _inputDeco(
        hint: '••••••••',
        icon: CupertinoIcons.lock, // ✅
        suffix: GestureDetector(
          onTap: () => setState(() => _obscurePass = !_obscurePass),
          child: Icon(
            _obscurePass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.textGray,
            size: 20,
          ), // ✅
        ),
      ),
    );
  }

  Widget _buildConfirmField() {
    return TextFormField(
      controller: _confirmCtrl,
      obscureText: _obscureConfirm,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Confirmation requise';
        if (v != _passCtrl.text)
          return 'Les mots de passe ne correspondent pas';
        return null;
      },
      decoration: _inputDeco(
        hint: '••••••••',
        icon: CupertinoIcons.lock, // ✅
        suffix: GestureDetector(
          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
          child: Icon(
            _obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.textGray,
            size: 20,
          ), // ✅
        ),
      ),
    );
  }

  Widget _buildRegisterBtn() {
    return GestureDetector(
      onTap: _loading ? null : _register,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _loading
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _loading
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
          child: _loading
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
