import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _code = 'FOUQUET2024';

  // ── Helper Nunito ──────────────────────────────────────────────────────────
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

  final List<Map<String, String>> _reductions = const [
    {
      'title': '10% sur votre prochaine commande',
      'desc': 'Valable jusqu\'au 31/12/2024',
      'code': 'SAVE10',
    },
    {
      'title': 'Livraison offerte',
      'desc': 'Pour toute commande > 5 000 FCFA',
      'code': 'FREELIV',
    },
    {
      'title': '500 FCFA offerts',
      'desc': 'Sur votre 3e commande',
      'code': 'BONUS500',
    },
  ];

  final List<Map<String, String>> _history = const [
    {
      'name': 'Kofi A.',
      'date': '12 Jan 2024',
      'status': 'Validé',
      'points': '+200',
    },
    {
      'name': 'Amina B.',
      'date': '03 Mar 2024',
      'status': 'En attente',
      'points': '+0',
    },
    {
      'name': 'Yemi C.',
      'date': '21 Avr 2024',
      'status': 'Validé',
      'points': '+200',
    },
  ];

  // ── Share Bottom Sheet ─────────────────────────────────────────────────────
  void _showShareSheet(BuildContext context) {
    const msg =
        'Rejoins Fouquet avec mon code $_code et profite d\'une réduction sur ta première commande ! 🍽️';

    final networks = [
      _ShareNetwork(
        label: 'WhatsApp',
        icon: FontAwesomeIcons.whatsapp,
        color: const Color(0xFF25D366),
        url: 'https://wa.me/?text=${Uri.encodeComponent(msg)}',
      ),
      _ShareNetwork(
        label: 'Facebook',
        icon: FontAwesomeIcons.facebookF,
        color: const Color(0xFF1877F2),
        url:
            'https://www.facebook.com/sharer/sharer.php?u=https://fouquet.com&quote=${Uri.encodeComponent(msg)}',
      ),
      _ShareNetwork(
        label: 'Instagram',
        icon: FontAwesomeIcons.instagram,
        color: const Color(0xFFE1306C),
        url: 'https://www.instagram.com/',
      ),
      _ShareNetwork(
        label: 'Telegram',
        icon: FontAwesomeIcons.telegram,
        color: const Color(0xFF0088CC),
        url:
            'https://t.me/share/url?url=https://fouquet.com&text=${Uri.encodeComponent(msg)}',
      ),
      _ShareNetwork(
        label: 'X (Twitter)',
        icon: FontAwesomeIcons.xTwitter,
        color: const Color(0xFF000000),
        url:
            'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(msg)}',
      ),
      _ShareNetwork(
        label: 'SMS',
        icon: FontAwesomeIcons.commentSms,
        color: const Color(0xFF34B7F1),
        url: 'sms:?body=${Uri.encodeComponent(msg)}',
      ),
      _ShareNetwork(
        label: 'Copier',
        icon: FontAwesomeIcons.copy,
        color: AppColors.primary,
        onTap: () {
          Clipboard.setData(const ClipboardData(text: msg));
          Get.back();
          Get.snackbar(
            'Copié !',
            'Message copié dans le presse-papiers',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            borderRadius: 14,
            margin: const EdgeInsets.all(16),
          );
        },
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Partager avec des amis',
              style: _nunito(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Code : $_code',
              style: _nunito(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: networks.map((n) => _buildNetworkItem(n)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkItem(_ShareNetwork n) {
    return GestureDetector(
      onTap:
          n.onTap ??
          () async {
            final uri = Uri.parse(n.url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: n.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: n.color.withOpacity(0.2)),
            ),
            child: Center(
              child: n.icon is IconData
                  ? Icon(n.icon as IconData, color: n.color, size: 24)
                  : FaIcon(n.icon as FaIconData, color: n.color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            n.label,
            style: _nunito(
              size: 11,
              weight: FontWeight.w600,
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
            _buildPointsCard(),
            const SizedBox(height: 24),
            _buildCodeCard(context),
            const SizedBox(height: 28),
            _buildSectionTitle('Réductions disponibles'),
            const SizedBox(height: 12),
            ..._reductions.map((r) => _buildReductionItem(r)),
            const SizedBox(height: 28),
            _buildSectionTitle('Historique des parrainages'),
            const SizedBox(height: 12),
            _buildHistoryList(),
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
      'Parrainage & Réductions',
      style: _nunito(
        size: 18,
        weight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  // ── Carte points ──────────────────────────────────────────────────────────
  Widget _buildPointsCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Text(
          'Vos points',
          style: _nunito(size: 13, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        Text(
          '1 400 pts',
          style: _nunito(
            size: 36,
            weight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '≈ 1 400 FCFA de réduction',
          style: _nunito(size: 13, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _pointStat('7', 'Filleuls'),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(0.3),
            ),
            _pointStat('200 pts', 'Par filleul validé'),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(0.3),
            ),
            _pointStat('3', 'Réductions utilisées'),
          ],
        ),
      ],
    ),
  );

  Widget _pointStat(String v, String l) => Column(
    children: [
      Text(
        v,
        style: _nunito(size: 16, weight: FontWeight.w800, color: Colors.white),
      ),
      const SizedBox(height: 2),
      Text(
        l,
        style: _nunito(size: 10, color: Colors.white.withOpacity(0.75)),
        textAlign: TextAlign.center,
      ),
    ],
  );

  // ── Carte code ────────────────────────────────────────────────────────────
  Widget _buildCodeCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre code de parrainage',
          style: _nunito(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _code,
                  style: _nunito(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: _code));
                  Get.snackbar(
                    'Copié !',
                    'Code copié dans le presse-papiers',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    borderRadius: 14,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: Icon(
                  CupertinoIcons.doc_on_clipboard,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showShareSheet(context),
            icon: const Icon(CupertinoIcons.share, size: 18),
            label: Text(
              'Partager avec des amis',
              style: _nunito(
                size: 14,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Titre de section ──────────────────────────────────────────────────────
  Widget _buildSectionTitle(String t) => Text(
    t,
    style: _nunito(
      size: 15,
      weight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  // ── Item réduction ────────────────────────────────────────────────────────
  Widget _buildReductionItem(Map<String, String> r) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
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
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(CupertinoIcons.tag, color: AppColors.secondary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r['title']!,
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                r['desc']!,
                style: _nunito(size: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            r['code']!,
            style: _nunito(
              size: 11,
              weight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Historique ────────────────────────────────────────────────────────────
  Widget _buildHistoryList() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: List.generate(_history.length, (i) {
        final h = _history[i];
        final isValid = h['status'] == 'Validé';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isValid
                          ? Colors.green.withOpacity(0.1)
                          : const Color.fromARGB(
                              255,
                              255,
                              0,
                              106,
                            ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isValid
                          ? CupertinoIcons.checkmark_circle
                          : CupertinoIcons.clock,
                      color: isValid
                          ? Colors.green
                          : const Color.fromARGB(255, 255, 0, 106),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['name']!,
                          style: _nunito(
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          h['date']!,
                          style: _nunito(size: 12, color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        h['points']!,
                        style: _nunito(
                          size: 14,
                          weight: FontWeight.w800,
                          color: isValid
                              ? Colors.green
                              : const Color.fromARGB(255, 255, 0, 106),
                        ),
                      ),
                      Text(
                        h['status']!,
                        style: _nunito(
                          size: 11,
                          color: isValid
                              ? Colors.green
                              : const Color.fromARGB(255, 255, 0, 106),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (i < _history.length - 1)
              Divider(height: 1, indent: 66, color: AppColors.divider),
          ],
        );
      }),
    ),
  );
}

// ── Modèle réseau social ──────────────────────────────────────────────────────
class _ShareNetwork {
  final String label;
  final dynamic icon; // IconData ou FaIconData
  final Color color;
  final String? url;
  final VoidCallback? onTap;

  const _ShareNetwork({
    required this.label,
    required this.icon,
    required this.color,
    this.url,
    this.onTap,
  });
}
