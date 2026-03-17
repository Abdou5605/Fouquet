import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/features/cart/presentation/cart_screen.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _selectedNav = 0;
  int _currentBanner = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  final List<String> _categories = [
    'Tous',
    'Fast Food',
    'Plats Africains',
    'Boissons',
    'Salades',
    'Cocktails',
    'Desserts',
    'Cremeries',
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
    },
    {
      'name': 'Pizza Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
      'category': 'Plats Africains',
    },
    {
      'name': 'Shawarma Royal',
      'price': 3000,
      'oldPrice': 6000,
      'image': AppImages.frite,
      'badge': '9%\nOFF',
      'badgeColor': AppColors.badgeOff,
      'category': 'Fast Food',
    },
    {
      'name': 'Salade Fouquet',
      'price': 7500,
      'oldPrice': null,
      'image': AppImages.raisin,
      'badge': 'TOP\nSALE',
      'badgeColor': AppColors.badgeOff,
      'category': 'Salades',
    },
    {
      'name': 'Mini Burger',
      'price': 2500,
      'oldPrice': null,
      'image': AppImages.viande,
      'badge': null,
      'badgeColor': null,
      'category': 'Fast Food',
    },
    {
      'name': 'Pizza Royale',
      'price': 8500,
      'oldPrice': null,
      'image': AppImages.rizaugras,
      'badge': null,
      'badgeColor': null,
      'category': 'Plats Africains',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          _buildHomeBody(),
          // ✅ onBack ramène sur l'onglet Home
          CartScreen(onBack: () => setState(() => _selectedNav = 0)),
          FavoritesScreen(onBack: () => setState(() => _selectedNav = 0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody() {
    final products = _filteredProducts;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: _buildBannerCarousel()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildCategoriesHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildCategories()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildSearchBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          products.isEmpty
              ? SliverToBoxAdapter(child: _buildEmpty())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildProductCard(products[i]),
                      childCount: products.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Container(
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
          ),
          const SizedBox(width: 12),
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
          GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.bell,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            children: [_buildPromoBanner(), _buildBookSpaceBanner()],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBanner == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBanner == i
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
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
                      color: AppColors.primary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Super Discount',
                    style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.cart),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Commander',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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

  Widget _buildBookSpaceBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.bookSpace),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppImages.rizaugras,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.secondary.withOpacity(0.8)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.secondary.withOpacity(0.3),
                        AppColors.secondary.withOpacity(0.92),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Événements & Privatisation',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Réservez\nnotre espace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Réserver maintenant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.calendar_badge_plus,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.allProducts),
            child: Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Rechercher un plat…',
          hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
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

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(CupertinoIcons.search, size: 48, color: AppColors.textGray),
            const SizedBox(height: 12),
            Text(
              _query.isNotEmpty
                  ? 'Aucun résultat pour "$_query"'
                  : 'Aucun plat dans cette catégorie',
              style: TextStyle(fontSize: 14, color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
                          CupertinoIcons.square_favorites_alt,
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
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
                              color: AppColors.badgeOff,
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_right,
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

  Widget _buildBottomNav() {
    final items = [
      {'icon': CupertinoIcons.house_fill, 'label': 'Home'},
      {'icon': CupertinoIcons.shopping_cart, 'label': 'Panier'},
      {'icon': CupertinoIcons.heart, 'label': 'Favoris'},
      {'icon': CupertinoIcons.person, 'label': 'Profil'},
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
