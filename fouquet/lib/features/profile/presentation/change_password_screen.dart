import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConf = true;
  bool _loading = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    Get.back();
    Get.snackbar(
      'Succès',
      'Mot de passe modifié avec succès',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 32),
              _buildLabel('Ancien mot de passe'),
              const SizedBox(height: 8),
              _buildField(
                ctrl: _oldCtrl,
                hint: '••••••••',
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Nouveau mot de passe'),
              const SizedBox(height: 8),
              _buildField(
                ctrl: _newCtrl,
                hint: '••••••••',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v.length < 6) return 'Minimum 6 caractères';
                  if (v == _oldCtrl.text)
                    return 'Doit être différent de l\'ancien';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildPasswordStrength(_newCtrl.text),
              const SizedBox(height: 20),
              _buildLabel('Confirmer le mot de passe'),
              const SizedBox(height: 8),
              _buildField(
                ctrl: _confCtrl,
                hint: '••••••••',
                obscure: _obscureConf,
                onToggle: () => setState(() => _obscureConf = !_obscureConf),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v != _newCtrl.text)
                    return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _buildSubmitBtn(),
            ],
          ),
        ),
      ),
    );
  }

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
        ), // ✅
      ),
    ),
    title: Text(
      'Mot de passe',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(CupertinoIcons.shield, color: AppColors.primary, size: 32), // ✅
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Utilisez un mot de passe fort d\'au moins 6 caractères, avec des chiffres et des symboles.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
      letterSpacing: 0.2,
    ),
  );

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        prefixIcon: Icon(
          CupertinoIcons.lock,
          color: AppColors.primary,
          size: 20,
        ), // ✅
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: AppColors.textGray,
              size: 20,
            ), // ✅
          ),
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

  Widget _buildPasswordStrength(String pwd) {
    int strength = 0;
    if (pwd.length >= 6) strength++;
    if (pwd.contains(RegExp(r'[A-Z]'))) strength++;
    if (pwd.contains(RegExp(r'[0-9]'))) strength++;
    if (pwd.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
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
          style: TextStyle(
            fontSize: 12,
            color: colors[strength],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitBtn() => GestureDetector(
    onTap: _loading ? null : _submit,
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
                  color: AppColors.primary.withOpacity(0.3),
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
                'Enregistrer',
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
