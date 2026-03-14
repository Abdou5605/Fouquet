import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/features/cart/presentation/cart_screen.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _selectedNav = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeBody(),
      const CartScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
  }

  final List<String> _categories = [
    'All',
    'Burgers',
    'Pizzas',
    'Shawarmas',
    'Salades',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'King Burger',
      'price': 4000,
      'oldPrice': 5000,
      'image': AppImages.viande,
      'badge': 'TOP\nSALE',
      'badgeColor': AppColors.badgeOff,
    },
    {
      'name': 'Pizza Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
    },
    {
      'name': 'Shawarma Royal',
      'price': 3000,
      'oldPrice': 6000,
      'image': AppImages.frite,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
    },
    {
      'name': 'Salade Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.raisin,
      'badge': 'TOP\nSALE',
      'badgeColor': AppColors.badgeOff,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: IndexedStack(index: _selectedNav, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Corps Home ─────────────────────────────────────────────
  Widget _buildHomeBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildPromoBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader('Catégories', 'Voir tout', () {}),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildCategories()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _buildSectionHeader('Nos Plats', 'Voir tout', () {}),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _buildProductCard(_products[i]),
                childCount: _products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      // ✅ Bandeau vert en haut
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          // Avatar avec bordure blanche
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              backgroundImage: const AssetImage(AppImages.onboardAsiatique),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 12),

          // Greeting — texte blanc sur fond vert
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jhon Anderson',
                  style: AppTextStyles.greetingName.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Good Morning 👋',
                  style: AppTextStyles.greetingText.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          // Bouton search blanc
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Promo Banner ───────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          // ✅ Fond vert clair au lieu de beige
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset(
                AppImages.frite,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 170,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withOpacity(0.10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Badge rose "Today Only"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Today Only',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '20% OFF',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary, // ✅ vert
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Super Discount',
                    style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary, // ✅ vert
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Commander',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary, // ✅ rose
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories ─────────────────────────────────────────────
  Widget _buildCategories() {
    return SizedBox(
      height: 38,
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
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                // ✅ Catégorie active = vert primary
                color: selected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Product Card ───────────────────────────────────────────
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
                        child: const Icon(
                          Icons.restaurant,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary, // ✅ prix en vert
                            ),
                          ),
                          if (product['oldPrice'] != null)
                            Text(
                              '${product['oldPrice']} F',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGray,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      // ✅ Bouton flèche vert
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
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

  // ── Bottom Navigation Bar ──────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.shopping_bag_outlined, 'label': 'Cart'},
      {'icon': Icons.favorite_border_rounded, 'label': 'Favoris'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedNav == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedNav = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    // ✅ Fond vert transparent pour l'item actif
                    color: selected
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        // ✅ Icône verte si actif
                        color: selected
                            ? AppColors.primary
                            : AppColors.textGray,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                      ),
                      if (selected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            // ✅ Indicateur vert
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
