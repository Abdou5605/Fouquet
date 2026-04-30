import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class BookSpaceScreen extends StatelessWidget {
  const BookSpaceScreen({super.key});

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

  // ── Numéro du restaurant ── À MODIFIER ────────────────
  static const String _phone = '+229 XX XX XX XX';
  static const String _phoneDialable = '+229XXXXXXXX';

  // ── Appel téléphonique ────────────────────────────────
  Future<void> _callRestaurant() async {
    final uri = Uri.parse('tel:$_phoneDialable');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le téléphone.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.secondary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 14,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ── WhatsApp ──────────────────────────────────────────
  Future<void> _whatsapp() async {
    final number = _phoneDialable.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Erreur',
        'WhatsApp n\'est pas installé sur cet appareil.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.secondary.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 14,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ── Copier le numéro ──────────────────────────────────
  void _copyNumber() {
    Clipboard.setData(ClipboardData(text: _phone));
    Get.snackbar(
      'Copié !',
      'Le numéro a été copié dans le presse-papiers.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      icon: const Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: Colors.white,
      ),
    );
  }

  static const List<Map<String, String>> _reservationTypes = [
    {
      'emoji': '🍽️',
      'title': 'Réservation de table',
      'desc':
          'Réservez votre table pour un dîner ou déjeuner en toute tranquillité.',
    },
    {
      'emoji': '🎂',
      'title': 'Anniversaire',
      'desc': 'Fêtez vos anniversaires dans un cadre chaleureux et festif.',
    },
    {
      'emoji': '🙏',
      'title': 'Baptême',
      'desc': 'Célébrez l\'arrivée de votre petit bonheur avec vos proches.',
    },
    {
      'emoji': '💍',
      'title': 'Fiançailles',
      'desc': 'Un moment unique et inoubliable pour officialiser votre amour.',
    },
    {
      'emoji': '👨‍👩‍👧‍👦',
      'title': 'Repas en famille',
      'desc': 'Rassemblez toute la famille autour d\'une belle table.',
    },
    {
      'emoji': '💼',
      'title': 'Réunion d\'affaires',
      'desc':
          'Un espace privatisé et professionnel pour vos rencontres business.',
    },
    {
      'emoji': '🎉',
      'title': 'Privatisation de l\'espace',
      'desc': 'Réservez tout l\'espace pour votre événement sur mesure.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
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
          'Réservations',
          style: _nunito(
            size: 18,
            weight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      // ✅ Boutons figés en bas
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 28),
            _buildIntroText(),
            const SizedBox(height: 28),
            Text(
              'Ce que nous proposons',
              style: _nunito(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            ..._reservationTypes.map((r) => _buildReservationCard(r)),
            const SizedBox(height: 28),
            _buildPhoneCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Réservez chez nous',
            style: _nunito(
              size: 22,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tables, événements privés, fêtes… nous sommes là pour rendre chaque moment spécial.',
            style: _nunito(
              size: 13,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Intro ─────────────────────────────────────────────
  Widget _buildIntroText() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Comment réserver ?',
                style: _nunito(
                  size: 14,
                  weight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pour effectuer une réservation — que ce soit pour une table ou un événement privé — il vous suffit de nous contacter directement par téléphone ou WhatsApp. Notre équipe se fera un plaisir de vous accompagner.',
            style: _nunito(size: 13, color: AppColors.textGray, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Carte type réservation ────────────────────────────
  Widget _buildReservationCard(Map<String, String> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(r['emoji']!, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['title']!,
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r['desc']!,
                  style: _nunito(
                    size: 12,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte numéro avec bouton copier ───────────────────
  Widget _buildPhoneCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.phone_fill,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appelez-nous',
                  style: _nunito(
                    size: 12,
                    color: AppColors.textGray,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _phone,
                  style: _nunito(
                    size: 16,
                    weight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // ✅ Bouton copier
          GestureDetector(
            onTap: _copyNumber,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CupertinoIcons.doc_on_clipboard,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre fixe en bas ─────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Bouton Appeler (en haut) ────────────────
          GestureDetector(
            onTap: _callRestaurant,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.phone_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Appeler',
                    style: _nunito(
                      size: 14,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── Bouton WhatsApp (en bas) ────────────────
          GestureDetector(
            onTap: _whatsapp,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withOpacity(0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.chat_bubble_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WhatsApp',
                    style: _nunito(
                      size: 14,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
