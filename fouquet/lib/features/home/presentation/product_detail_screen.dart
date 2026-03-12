import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ── Données reçues depuis HomeScreen via Get.arguments ─────
  late final Map<String, dynamic> product;

  int _qty = 1;
  int _selectedSize = 1; // 0 = S, 1 = M, 2 = L
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _sizes = [
    {'label': 'S', 'extra': 0},
    {'label': 'M', 'extra': 500},
    {'label': 'L', 'extra': 1000},
  ];

  // Ingrédients fictifs — à remplacer par les vraies données
  final List<Map<String, dynamic>> _ingredients = [
    {'icon': '🥩', 'label': 'Viande'},
    {'icon': '🧀', 'label': 'Fromage'},
    {'icon': '🥬', 'label': 'Laitue'},
    {'icon': '🍅', 'label': 'Tomate'},
    {'icon': '🧅', 'label': 'Oignon'},
  ];

  int get _unitPrice =>
      (product['price'] as int) + (_sizes[_selectedSize]['extra'] as int);
  int get _total => _unitPrice * _qty;

  @override
  void initState() {
    super.initState();
    // Récupère les arguments passés depuis HomeScreen
    product = Get.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // ── Contenu scrollable ───────────────────────
          CustomScrollView(
            slivers: [
              // ── Image Hero + AppBar flottante ────────
              _buildSliverAppBar(),

              // ── Corps ────────────────────────────────
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
                      const SizedBox(height: 20),

                      // Nom + badge
                      _buildNameRow(),
                      const SizedBox(height: 12),

                      // Note + temps de préparation
                      _buildMetaRow(),
                      const SizedBox(height: 20),

                      // Description
                      _buildDescription(),
                      const SizedBox(height: 24),

                      // Ingrédients
                      _buildIngredients(),
                      const SizedBox(height: 24),

                      // Taille
                      _buildSizeSelector(),
                      const SizedBox(height: 24),

                      // Quantité
                      _buildQtyRow(),
                      const SizedBox(height: 120), // espace pour le bouton bas
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bouton "Ajouter au panier" fixe en bas ───
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  // ── SliverAppBar avec image Hero ───────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.bgLight,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 18,
          ),
        ),
      ),
      actions: [
        // Bouton favori
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
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.secondary : AppColors.textGray,
              size: 20,
            ),
          ),
        ),
        // Bouton partage
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.share_outlined,
            color: AppColors.textDark,
            size: 20,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product['name']}',
          child: Image.asset(
            product['image'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.bgLight,
              child: const Icon(
                Icons.restaurant,
                size: 80,
                color: AppColors.textGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Nom + badge ────────────────────────────────────────────
  Widget _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              product['name'],
              style: const TextStyle(
                fontSize: 24,
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

  // ── Note + temps ───────────────────────────────────────────
  Widget _buildMetaRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Étoile
          Icon(Icons.star_rounded, color: AppColors.star, size: 18),
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

          // Temps
          Icon(Icons.access_time_rounded, color: AppColors.textGray, size: 16),
          const SizedBox(width: 4),
          Text(
            '15–20 min',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          const SizedBox(width: 20),

          // Calories
          Icon(
            Icons.local_fire_department_outlined,
            color: AppColors.accent,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '320 kcal',
            style: TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  // ── Description ────────────────────────────────────────────
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

  // ── Ingrédients ────────────────────────────────────────────
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

  // ── Sélecteur de taille ────────────────────────────────────
  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taille',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_sizes.length, (i) {
              final selected = _selectedSize == i;
              final extra = _sizes[i]['extra'] as int;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _sizes[i]['label'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      if (extra > 0)
                        Text(
                          '+$extra F',
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? Colors.white70
                                : AppColors.textGray,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Sélecteur de quantité ──────────────────────────────────
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
          // Bouton –
          _QtyBtn(
            icon: Icons.remove,
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
          // Bouton +
          _QtyBtn(
            icon: Icons.add,
            onTap: () => setState(() => _qty++),
            filled: true,
          ),
        ],
      ),
    );
  }

  // ── Barre bas "Ajouter au panier" ──────────────────────────
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
      child: Row(
        children: [
          // Prix total
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prix total',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              Text(
                '$_total F CFA',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Bouton ajouter
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: ajouter au CartController
                Get.back();
                Get.snackbar(
                  'Panier',
                  '${product['name']} ajouté au panier !',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.accent,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
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
          ),
        ],
      ),
    );
  }
}

// ── Bouton quantité ───────────────────────────────────────────
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
          color: filled ? AppColors.accent : AppColors.bgLight,
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
