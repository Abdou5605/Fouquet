import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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

  // ── Coordonnées ───────────────────────────────────────────────────────────
  static const _num1Display = '01 94 94 21 70';
  static const _num1Dial = '+22901949421 70';
  static const _num2Display = '01 91 39 14 14';
  static const _num2Dial = '+22901913914 14';
  static const _email = 'contact@fouquet.com';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir ce lien.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.secondary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 14,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 24),

            // ── Appel ─────────────────────────────────────────────────────
            Text(
              'Appeler',
              style: _nunito(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildChannelTile(
              icon: CupertinoIcons.phone,
              label: 'Téléphone',
              value: _num1Display,
              color: Colors.blue,
              onTap: () => _launch('tel:$_num1Dial'),
            ),
            _buildChannelTile(
              icon: CupertinoIcons.phone,
              label: 'Téléphone',
              value: _num2Display,
              color: Colors.blue,
              onTap: () => _launch('tel:$_num2Dial'),
            ),
            const SizedBox(height: 20),

            // ── WhatsApp ──────────────────────────────────────────────────
            Text(
              'WhatsApp',
              style: _nunito(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildChannelTile(
              faIcon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              value: _num1Display,
              color: const Color(0xFF25D366),
              onTap: () => _launch(
                'https://wa.me/${_num1Dial.replaceAll(RegExp(r'[^\d]'), '')}',
              ),
            ),
            _buildChannelTile(
              faIcon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              value: _num2Display,
              color: const Color(0xFF25D366),
              onTap: () => _launch(
                'https://wa.me/${_num2Dial.replaceAll(RegExp(r'[^\d]'), '')}',
              ),
            ),
            const SizedBox(height: 20),

            // ── Email ─────────────────────────────────────────────────────
            Text(
              'Email',
              style: _nunito(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildChannelTile(
              icon: CupertinoIcons.mail,
              label: 'Email',
              value: _email,
              color: Colors.orange,
              onTap: () => _launch('mailto:$_email'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
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
      'Nous contacter',
      style: _nunito(
        size: 18,
        weight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  // ── Bannière ──────────────────────────────────────────────────────────────
  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            CupertinoIcons.person_2,
            color: Colors.white,
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
                style: _nunito(
                  size: 15,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Réponse garantie sous 24h en semaine.',
                style: _nunito(
                  size: 12,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Tuile canal ───────────────────────────────────────────────────────────
  Widget _buildChannelTile({
    IconData? icon,
    dynamic faIcon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: faIcon != null
                ? Center(
                    child: FaIcon(
                      faIcon as FaIconData?,
                      color: color,
                      size: 22,
                    ),
                  )
                : Icon(icon!, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _nunito(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  value,
                  style: _nunito(size: 13, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.textGray,
            size: 16,
          ),
        ],
      ),
    ),
  );
}
