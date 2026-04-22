import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedCategory = 0;

  // ── Helper Nunito ──────────────────────────────────────────────────────────
  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.0,
    double letterSpacing = 0.0,
    TextDecoration? decoration,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );

  final List<String> _categories = [
    'Tous',
    'Fast Food',
    'Plats Africains',
    'Plats Européens',
    'Boissons',
    'Déjeuners',
    'Cocktails',
    'Desserts',
    'Cremeries',
  ];

  // ✅ 9 icônes — une par catégorie
  final List<IconData> _catIcons = [
    CupertinoIcons.square_grid_2x2,
    CupertinoIcons.flame,
    CupertinoIcons.leaf_arrow_circlepath,
    CupertinoIcons.drop,
    CupertinoIcons.tree,
    CupertinoIcons.sun_max,
    CupertinoIcons.sparkles,
    CupertinoIcons.star,
    CupertinoIcons.snow,
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'King Burger',
      'price': 4000,
      'oldPrice': 5000,
      'image': AppImages.viande,
      'badge': 'TOP\nSALE',
      'badgeColor': AppColors.badgeOff,
      'category': 'Fast Food',
      'rating': 4.8,
    },
    {
      'name': 'Pizza Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
      'category': 'Plats Africains',
      'rating': 4.9,
    },
    {
      'name': 'Shawarma Royal',
      'price': 3000,
      'oldPrice': 6000,
      'image': AppImages.frite,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
      'category': 'Fast Food',
      'rating': 4.7,
    },
    {
      'name': 'Salade Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.raisin,
      'badge': 'TOP\nSALE',
      'badgeColor': AppColors.badgeOff,
      'category': 'Salades',
      'rating': 4.5,
    },
    {
      'name': 'Mini Burger',
      'price': 2500,
      'oldPrice': null,
      'image': AppImages.viande,
      'badge': null,
      'badgeColor': null,
      'category': 'Fast Food',
      'rating': 4.3,
    },
    {
      'name': 'Pizza Royale',
      'price': 8500,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': null,
      'badgeColor': null,
      'category': 'Plats Africains',
      'rating': 4.6,
    },
    {
      'name': 'Jus de Bissap',
      'price': 1000,
      'oldPrice': null,
      'image': AppImages.raisin,
      'badge': null,
      'badgeColor': null,
      'category': 'Boissons',
      'rating': 4.4,
    },
    {
      'name': 'Cocktail Fouquet',
      'price': 3500,
      'oldPrice': null,
      'image': AppImages.raisin,
      'badge': 'NEW',
      'badgeColor': AppColors.primary,
      'category': 'Cocktails',
      'rating': 4.8,
    },
    {
      'name': 'Riz au Gras',
      'price': 2000,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': null,
      'badgeColor': null,
      'category': 'Plats Africains',
      'rating': 4.7,
    },
    {
      'name': 'Glace Vanille',
      'price': 1500,
      'oldPrice': null,
      'image': AppImages.frite,
      'badge': null,
      'badgeColor': null,
      'category': 'Cremeries',
      'rating': 4.5,
    },
    {
      'name': 'Fondant Choco',
      'price': 2000,
      'oldPrice': null,
      'image': AppImages.viande,
      'badge': 'NEW',
      'badgeColor': AppColors.primary,
      'category': 'Desserts',
      'rating': 4.9,
    },
    {
      'name': 'Salade Caesar',
      'price': 4500,
      'oldPrice': 5000,
      'image': AppImages.raisin,
      'badge': null,
      'badgeColor': null,
      'category': 'Salades',
      'rating': 4.6,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    final cat = _categories[_selectedCategory];
    return _products.where((p) {
      final matchCat = cat == 'Tous' || p['category'] == cat;
      final matchQuery =
          _query.isEmpty ||
          (p['name'] as String).toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 4),
            _buildResultCount(),
            const SizedBox(height: 8),
            Expanded(child: _filtered.isEmpty ? _buildEmpty() : _buildGrid()),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
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
                  CupertinoIcons.arrow_left,
                  color: AppColors.textDark,
                  size: 18,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notre Menu',
                style: _nunito(
                  size: 20,
                  weight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${_products.length} plats disponibles',
                style: _nunito(size: 13, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Barre de recherche ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: _nunito(size: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Rechercher un plat…',
          hintStyle: _nunito(size: 14, color: AppColors.textGray),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchCtrl.clear();
                    _query = '';
                  }),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textGray,
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.bgCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
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
        ),
      ),
    );
  }

  // ── Chips catégories ──────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _catIcons[i],
                    color: selected ? Colors.white : AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _categories[i],
                    textAlign: TextAlign.center,
                    style: _nunito(
                      size: 10,
                      weight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Compteur résultats ────────────────────────────────────────────────────
  Widget _buildResultCount() {
    final count = _filtered.length;
    final cat = _categories[_selectedCategory];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '$count plat${count > 1 ? 's' : ''}${cat != 'Tous' ? ' · $cat' : ''}',
            style: _nunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
          if (_query.isNotEmpty) ...[
            Text(
              ' pour "',
              style: _nunito(size: 13, color: AppColors.textGray),
            ),
            Text(
              _query,
              style: _nunito(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text('"', style: _nunito(size: 13, color: AppColors.textGray)),
          ],
        ],
      ),
    );
  }

  // ── Grille produits ───────────────────────────────────────────────────────
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      itemCount: _filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) => _buildProductCard(_filtered[i]),
    );
  }

  // ── Carte produit ─────────────────────────────────────────────────────────
  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.asset(
                      product['image'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgLight,
                        child: Icon(
                          CupertinoIcons.photo,
                          color: AppColors.textGray,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  if (product['badge'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product['badgeColor'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['badge'],
                          textAlign: TextAlign.center,
                          style: _nunito(
                            size: 9,
                            weight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            color: AppColors.star,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product['rating']}',
                            style: _nunito(
                              size: 10,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: _nunito(
                      size: 13,
                      weight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['category'],
                    style: _nunito(size: 11, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product['price']} F',
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w800,
                              color: AppColors.badgeOff,
                            ),
                          ),
                          if (product['oldPrice'] != null)
                            Text(
                              '${product['oldPrice']} F',
                              style: _nunito(
                                size: 11,
                                color: AppColors.textGray,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.cart_badge_plus,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, size: 52, color: AppColors.textGray),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'Aucun résultat pour "$_query"'
                : 'Aucun plat dans cette catégorie',
            style: _nunito(size: 14, color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = 0;
              _searchCtrl.clear();
              _query = '';
            }),
            child: Text(
              'Voir tous les plats',
              style: _nunito(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
