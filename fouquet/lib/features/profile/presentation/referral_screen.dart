import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fouquet/features/profile/controller/referral_controller.dart';
import 'package:fouquet/features/profile/service/referral_api_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  PromoCodeController get _ctrl => Get.find<PromoCodeController>();

  void _ensureController() {
    if (!Get.isRegistered<PromoCodeController>()) {
      Get.put(PromoCodeController());
    }
  }

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

  // ── Share sheet ───────────────────────────────────────────────────────────
  void _showShareSheet(BuildContext context, String code) {
    final msg =
        'Rejoins Fouquet avec mon code $code et profite d\'une réduction sur ta première commande ! 🍽️';

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
          Clipboard.setData(ClipboardData(text: msg));
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
              'Code : $code',
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
            if (await canLaunchUrl(uri))
              await launchUrl(uri, mode: LaunchMode.externalApplication);
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
              child: FaIcon(n.icon as FaIconData?, color: n.color, size: 24),
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
    _ensureController();
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _ctrl.fetchAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointsCard(),
                const SizedBox(height: 24),
                _buildCodeCard(context),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 28),
                _buildSectionTitle('Réductions disponibles'),
                const SizedBox(height: 12),
                _buildPromoList(),
                const SizedBox(height: 28),
                _buildSectionTitle('Récompenses de parrainage'),
                const SizedBox(height: 12),
                _buildRewardsList(),
                const SizedBox(height: 28),
                _buildSectionTitle('Historique des parrainages'),
                const SizedBox(height: 12),
                _buildHistoryList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
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

  // ── Carte points (données réelles) ────────────────────────────────────────
  Widget _buildPointsCard() {
    final pts = _ctrl.points;
    return Container(
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
            pts != null ? '${pts.total} pts' : '— pts',
            style: _nunito(
              size: 36,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pts != null ? '≈ ${pts.equivalentFcfa} FCFA de réduction' : '',
            style: _nunito(size: 13, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _pointStat('${pts?.filleuls ?? 0}', 'Filleuls'),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.3),
              ),
              _pointStat(
                '${pts?.pointsParFilleul ?? 0} pts',
                'Par filleul validé',
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.3),
              ),
              _pointStat(
                '${pts?.reductionsUtilisees ?? 0}',
                'Réductions utilisées',
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  // ── Carte code (code réel depuis l'API) ───────────────────────────────────
  Widget _buildCodeCard(BuildContext context) {
    return Obx(() {
      final code = _ctrl.referralCode;
      return Container(
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
                      code,
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
                      Clipboard.setData(ClipboardData(text: code));
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
                onPressed: () => _showShareSheet(context, code),
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
    });
  }

  // ── Barre de recherche ────────────────────────────────────────────────────
  Widget _buildSearchBar() => TextField(
    onChanged: (v) => _ctrl.searchQuery.value = v,
    style: _nunito(size: 14, color: AppColors.textDark),
    decoration: InputDecoration(
      hintText: 'Rechercher un code ou une réduction…',
      hintStyle: _nunito(size: 13, color: AppColors.textGray),
      prefixIcon: const Icon(
        CupertinoIcons.search,
        size: 18,
        color: AppColors.textGray,
      ),
      suffixIcon: Obx(
        () => _ctrl.searchQuery.value.isNotEmpty
            ? GestureDetector(
                onTap: () => _ctrl.searchQuery.value = '',
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 18,
                  color: AppColors.textGray,
                ),
              )
            : const SizedBox.shrink(),
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: _nunito(
      size: 15,
      weight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  // ── Liste promos (/promo-codes) ───────────────────────────────────────────
  Widget _buildPromoList() {
    final items = _ctrl.filtered;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Aucune réduction disponible',
            style: _nunito(size: 13, color: AppColors.textGray),
          ),
        ),
      );
    }
    return Column(children: items.map((r) => _buildPromoItem(r)).toList());
  }

  Widget _buildPromoItem(Map<String, dynamic> r) => Container(
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
                (r['description'] ?? r['code']) as String,
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (r['value'] != null)
                Text(
                  r['type_reduction'] == 'percentage'
                      ? '${r['value']}% de réduction'
                      : '${r['value']} FCFA de réduction',
                  style: _nunito(size: 12, color: AppColors.textGray),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: r['code'] as String));
            Get.snackbar(
              'Copié !',
              'Code "${r['code']}" copié',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
              borderRadius: 14,
              margin: const EdgeInsets.all(16),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              r['code'] as String,
              style: _nunito(
                size: 11,
                weight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Récompenses de parrainage (/referral → rewards) ───────────────────────
  Widget _buildRewardsList() {
    final rewards = _ctrl.rewards;
    if (rewards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Aucune récompense pour l\'instant',
            style: _nunito(size: 13, color: AppColors.textGray),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(rewards.length, (i) {
          final r = rewards[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.gift,
                        color: Colors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: _nunito(
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            r.rewardDate,
                            style: _nunito(size: 12, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: r.code));
                        Get.snackbar(
                          'Copié !',
                          'Code "${r.code}" copié',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          borderRadius: 14,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.code,
                          style: _nunito(
                            size: 11,
                            weight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rewards.length - 1)
                Divider(height: 1, indent: 72, color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }

  // ── Historique des parrainages (/referral → referrals) ────────────────────
  Widget _buildHistoryList() {
    final refs = _ctrl.referrals;
    if (refs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Aucun parrainage pour l\'instant',
            style: _nunito(size: 13, color: AppColors.textGray),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(refs.length, (i) {
          final h = refs[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: h.isValidated
                            ? Colors.green.withOpacity(0.1)
                            : const Color(0xFFFF006A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        h.isValidated
                            ? CupertinoIcons.checkmark_circle
                            : CupertinoIcons.clock,
                        color: h.isValidated
                            ? Colors.green
                            : const Color(0xFFFF006A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name,
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            h.referralDate,
                            style: _nunito(size: 12, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          h.isValidated ? '+${h.points}' : '+0',
                          style: _nunito(
                            size: 14,
                            weight: FontWeight.w800,
                            color: h.isValidated
                                ? Colors.green
                                : const Color(0xFFFF006A),
                          ),
                        ),
                        Text(
                          h.isValidated ? 'Validé' : 'En attente',
                          style: _nunito(
                            size: 11,
                            color: h.isValidated
                                ? Colors.green
                                : const Color(0xFFFF006A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < refs.length - 1)
                Divider(height: 1, indent: 66, color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }
}

// ── Modèle réseau social ──────────────────────────────────────────────────────
class _ShareNetwork {
  final String label;
  final dynamic icon;
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
