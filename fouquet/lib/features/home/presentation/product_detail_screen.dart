import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fouquet/features/home/controllers/products_detail_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailController ctrl;

  @override
  void initState() {
    super.initState();
    // ✅ Utilise lazyPut + fenix dans app_pages.dart et Get.find() ici
    ctrl = Get.find<ProductDetailController>();
  }

  void _showShareSheet() {
    final dish = ctrl.dish.value;
    final name = dish?['name'] ?? '';
    final description = dish?['description'] ?? '';
    final shareText =
        '🍽️ $name\n$description\n\nDécouvrez ce plat sur Fouquet !';
    final encodedText = Uri.encodeComponent(shareText);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Partager via',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareItemFa(
                  FontAwesomeIcons.whatsapp,
                  'WhatsApp',
                  const Color(0xFF25D366),
                  () => ctrl.shareProduct(),
                ),
                _shareItemFa(
                  FontAwesomeIcons.facebook,
                  'Facebook',
                  const Color(0xFF1877F2),
                  () => ctrl.shareProduct(),
                ),
                _shareItemFa(
                  FontAwesomeIcons.instagram,
                  'Instagram',
                  const Color(0xFFE1306C),
                  () => ctrl.shareProduct(),
                ),
                _shareItemFa(
                  FontAwesomeIcons.xTwitter,
                  'X',
                  Colors.black,
                  () => ctrl.shareProduct(),
                ),
                _shareItemCupertino(
                  CupertinoIcons.link,
                  'Copier',
                  AppColors.primary,
                  () {
                    Clipboard.setData(ClipboardData(text: shareText));
                    Get.back();
                    Get.snackbar(
                      'Lien copié',
                      'Copié dans le presse-papiers',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                      borderRadius: 14,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareItemFa(
    FaIconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: () {
      Get.back();
      onTap();
    },
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: FaIcon(icon, color: color, size: 26)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
  Widget _shareItemCupertino(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) return _buildSkeleton();
      final dish = ctrl.dish.value;
      if (dish == null) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                CupertinoIcons.arrow_left,
                color: AppColors.textDark,
              ),
            ),
          ),
          body: Center(
            child: Text(
              'Plat introuvable',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
        );
      }

      // Extraction des champs du Map
      final name = dish['name'] as String;
      final description = dish['description'] as String;
      final image = dish['image'] as String?;
      final isAvailable =
          dish['is_available'] == 1 || dish['is_available'] == true;
      final cookingTime = dish['cooking_time'] as int?;
      final kcal = dish['kcal'] as int?;
      final avisCount = (dish['avis_count'] as int?) ?? 0;
      final category = dish['category'] as Map?;
      final catName = category?['name'] as String?;

      return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(image),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameRow(name, isAvailable),
                          const SizedBox(height: 8),
                          if (catName != null) _buildCategoryChip(catName),
                          const SizedBox(height: 12),
                          _buildMetaRow(avisCount, cookingTime, kcal),
                          const SizedBox(height: 20),
                          _buildDescription(description),
                          const SizedBox(height: 24),
                          _buildPriceRow(),
                          const SizedBox(height: 24),
                          _buildQtyRow(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(name, isAvailable),
            ),
          ],
        ),
      );
    });
  }

  // ── SliverAppBar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(String? image) {
    final h = MediaQuery.of(context).size.height;
    return SliverAppBar(
      expandedHeight: h * 0.5,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.arrow_left,
            color: AppColors.textDark,
            size: 18,
          ),
        ),
      ),
      actions: [
        // ✅ isLikeLoading protège contre les doubles appels
        Obx(
          () => GestureDetector(
            onTap: ctrl.isLikeLoading.value ? null : ctrl.toggleFavorite,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: ctrl.isLikeLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      ctrl.isFavorite.value
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: ctrl.isFavorite.value
                          ? AppColors.secondary
                          : AppColors.textGray,
                      size: 20,
                    ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _showShareSheet,
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.share,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: image != null
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder(),
              )
            : _imgPlaceholder(),
      ),
    );
  }

  Widget _buildNameRow(String name, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (!isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.textGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Indisponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String catName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          catName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(int avisCount, int? cookingTime, int? kcal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.star_fill, color: AppColors.star, size: 16),
              const SizedBox(width: 4),
              Text(
                '$avisCount avis',
                style: TextStyle(fontSize: 13, color: AppColors.textGray),
              ),
            ],
          ),
          if (cookingTime != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.clock, color: AppColors.textGray, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$cookingTime min',
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
              ],
            ),
          if (kcal != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.flame, color: AppColors.accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$kcal kcal',
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(
        () => Text(
          ctrl.formattedTotal,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.badgeOff,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text(
            'Quantité',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          _QtyBtn(
            icon: CupertinoIcons.minus,
            onTap: ctrl.decrement,
            filled: false,
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${ctrl.quantity.value}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          _QtyBtn(
            icon: CupertinoIcons.plus,
            onTap: ctrl.increment,
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String name, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        // APRÈS
        onTap: isAvailable
            ? () async {
                await ctrl.addToCart();
                Get.back();
                Get.snackbar(
                  'Panier ✓',
                  '$name ajouté au panier !',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  duration: const Duration(seconds: 2),
                );
              }
            : null,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.primary : AppColors.textGray,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isAvailable
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.shopping_cart,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAvailable ? 'Ajouter au panier' : 'Plat indisponible',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(height: 350, color: AppColors.divider),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 28, width: 200, color: AppColors.divider),
                const SizedBox(height: 12),
                Container(height: 14, width: 280, color: AppColors.divider),
                const SizedBox(height: 8),
                Container(height: 14, width: 240, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: AppColors.bgLight,
    child: Center(
      child: Icon(CupertinoIcons.photo, color: AppColors.textGray, size: 80),
    ),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.bgLight,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : AppColors.textDark,
          size: 18,
        ),
      ),
    );
  }
}
