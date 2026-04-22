import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final Map<String, dynamic> product;

  int _qty = 1;
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _ingredients = [
    {'icon': '🥩', 'label': 'Viande'},
    {'icon': '🧀', 'label': 'Fromage'},
    {'icon': '🥬', 'label': 'Laitue'},
    {'icon': '🍅', 'label': 'Tomate'},
    {'icon': '🧅', 'label': 'Oignon'},
  ];

  int get _unitPrice => product['price'] as int;
  int get _total => _unitPrice * _qty;

  @override
  void initState() {
    super.initState();
    product = Get.arguments as Map<String, dynamic>;
  }

  // ── Share sheet ────────────────────────────────────────────
  void _showShareSheet(BuildContext context) {
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
                  faIcon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => Get.back(),
                ),
                _shareItemFa(
                  faIcon: FontAwesomeIcons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => Get.back(),
                ),
                _shareItemFa(
                  faIcon: FontAwesomeIcons.instagram,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => Get.back(),
                ),
                _shareItemFa(
                  faIcon: FontAwesomeIcons.xTwitter,
                  label: 'X',
                  color: Colors.black,
                  onTap: () => Get.back(),
                ),
                _shareItemCupertino(
                  icon: CupertinoIcons.link,
                  label: 'Copier',
                  color: AppColors.primary,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Lien copié',
                      'Le lien a été copié dans le presse-papiers',
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

  // ── Item share FontAwesome ─────────────────────────────────
  Widget _shareItemFa({
    required FaIconData faIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
            child: Center(child: FaIcon(faIcon, color: color, size: 26)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Item share Cupertino (Copier) ──────────────────────────
  Widget _shareItemCupertino({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
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
                      _buildNameRow(),
                      const SizedBox(height: 12),
                      _buildMetaRow(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildIngredients(),
                      const SizedBox(height: 16),
                      _buildPriceRow(),
                      const SizedBox(height: 24),
                      _buildQtyRow(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SliverAppBar(
      expandedHeight: screenHeight * 0.5,
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
        GestureDetector(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: _isFavorite ? AppColors.secondary : AppColors.textGray,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () => _showShareSheet(context),
            child: const Icon(
              CupertinoIcons.share,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product['name']}',
          child: Image.asset(
            product['image'],
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white,
              child: const Icon(
                CupertinoIcons.photo,
                size: 80,
                color: AppColors.textGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              product['name'],
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (product['badge'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: product['badgeColor'],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                (product['badge'] as String).replaceAll('\n', ' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(CupertinoIcons.star_fill, color: AppColors.star, size: 18),
          const SizedBox(width: 4),
          const Text(
            '4.8',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Text(
            '  (128 avis)',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          const SizedBox(width: 20),
          Icon(CupertinoIcons.clock, color: AppColors.textGray, size: 16),
          const SizedBox(width: 4),
          Text(
            '15–20 min',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          const SizedBox(width: 20),
          Icon(CupertinoIcons.flame, color: AppColors.accent, size: 16),
          const SizedBox(width: 4),
          Text(
            '320 kcal',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            'Un délicieux plat préparé avec les meilleurs ingrédients frais, '
            'sélectionnés chaque matin pour vous offrir une expérience gustative unique. '
            'Saveurs intenses et texture parfaite garanties.',
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

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Ingrédients',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _ingredients.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final ing = _ingredients[i];
              return Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        ing['icon'],
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ing['label'],
                    style: TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '$_total F CFA',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.badgeOff,
            ),
          ),
          if (product['oldPrice'] != null) ...[
            const SizedBox(width: 10),
            Text(
              '${product['oldPrice']} F',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textGray,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQtyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            onTap: () {
              if (_qty > 1) setState(() => _qty--);
            },
            filled: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_qty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          _QtyBtn(
            icon: CupertinoIcons.plus,
            onTap: () => setState(() => _qty++),
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
        onTap: () {
          Get.back();
          Get.snackbar(
            'Panier',
            '${product['name']} ajouté au panier !',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
            duration: const Duration(seconds: 2),
          );
        },
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.shopping_cart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Ajouter au panier',
                style: TextStyle(
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
