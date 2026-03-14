import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController(text: 'Jhon');
  final _prenomCtrl = TextEditingController(text: 'Anderson');
  final _emailCtrl = TextEditingController(text: 'jhon.anderson@email.com');
  final _phoneCtrl = TextEditingController(text: '+229 97 00 00 00');
  final _adresseCtrl = TextEditingController(text: 'Cotonou, Bénin');

  bool _loading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // simuler API
    setState(() => _loading = false);
    Get.back();
    Get.snackbar(
      'Succès',
      'Profil mis à jour avec succès !',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.badgeOff,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Avatar ───────────────────────
                      _buildAvatar(),
                      const SizedBox(height: 32),

                      // ── Champs ───────────────────────
                      _buildField(
                        label: 'Nom',
                        controller: _nomCtrl,
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Prénom',
                        controller: _prenomCtrl,
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Email',
                        controller: _emailCtrl,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            !v!.contains('@') ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Téléphone',
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Adresse',
                        controller: _adresseCtrl,
                        icon: Icons.location_on_outlined,
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 32),

                      // ── Bouton Enregistrer ────────────
                      _buildSaveBtn(),
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

  // ── AppBar ─────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              AppImages.onboardAsiatique,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.bgLight,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.textGray,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {}, // TODO: image picker
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.badgeOff,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ texte ────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bouton Enregistrer ─────────────────────────────────────
  Widget _buildSaveBtn() {
    return GestureDetector(
      onTap: _loading ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _loading
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Enregistrer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
