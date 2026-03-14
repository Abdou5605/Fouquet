import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    _subjectCtrl.clear();
    _msgCtrl.clear();
    Get.snackbar(
      'Message envoyé 👍',
      'Nous vous répondrons dans les 24h.',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 24),
            _buildSectionTitle('Contactez-nous directement'),
            const SizedBox(height: 12),
            _buildChannels(),
            const SizedBox(height: 28),
            _buildSectionTitle('Envoyer un message'),
            const SizedBox(height: 12),
            _buildForm(),
          ],
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
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textDark,
          size: 18,
        ),
      ),
    ),
    title: Text(
      'Nous contacter',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.support_agent_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'On est là pour vous !',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Réponse garantie sous 24h en semaine.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  // ── Canaux de contact ──────────────────────────────────────
  Widget _buildChannels() {
    final channels = [
      _ContactChannel(
        icon: Icons.phone_outlined,
        label: 'Téléphone',
        value: '+229 01 23 45 67',
        color: Colors.blue,
        onTap: () => _launch('tel:+22901234567'),
      ),
      _ContactChannel(
        faIcon: FontAwesomeIcons.whatsapp,
        label: 'WhatsApp',
        value: '+229 01 23 45 67',
        color: const Color(0xFF25D366),
        onTap: () => _launch('https://wa.me/22901234567'),
      ),
      _ContactChannel(
        icon: Icons.email_outlined,
        label: 'Email',
        value: 'contact@fouquet.com',
        color: Colors.orange,
        onTap: () => _launch('mailto:contact@fouquet.com'),
      ),
    ];
    return Column(children: channels.map((c) => _buildChannelTile(c)).toList());
  }

  Widget _buildChannelTile(_ContactChannel c) => GestureDetector(
    onTap: c.onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: c.faIcon != null
                ? FaIcon(c.faIcon!, color: c.color, size: 22)
                : Icon(c.icon!, color: c.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  c.value,
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textGray,
            size: 16,
          ),
        ],
      ),
    ),
  );

  // ── Formulaire ─────────────────────────────────────────────
  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Sujet'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectCtrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          validator: (v) => (v == null || v.isEmpty) ? 'Sujet requis' : null,
          decoration: _inputDeco(
            hint: 'Ex : Problème avec ma commande',
            icon: Icons.title_rounded,
          ),
        ),
        const SizedBox(height: 20),
        _buildLabel('Message'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _msgCtrl,
          maxLines: 5,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Message requis';
            if (v.length < 10) return 'Message trop court';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Décrivez votre problème ou question…',
            hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding: const EdgeInsets.all(16),
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
        ),
        const SizedBox(height: 28),
        _buildSubmitBtn(),
        const SizedBox(height: 32),
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

  InputDecoration _inputDeco({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
      );

  Widget _buildSubmitBtn() => GestureDetector(
    onTap: _loading ? null : _sendMessage,
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
                'Envoyer',
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

class _ContactChannel {
  final IconData? icon;
  final dynamic faIcon;
  final String label, value;
  final Color color;
  final VoidCallback onTap;
  const _ContactChannel({
    this.icon,
    this.faIcon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
}
