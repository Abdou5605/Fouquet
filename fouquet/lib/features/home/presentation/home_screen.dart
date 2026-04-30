import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/cart/presentation/cart_screen.dart';
import 'package:fouquet/features/favorite/controller/favorite_controller.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/home/controllers/home_controller.dart';
import 'package:fouquet/features/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _menu;

  int _selectedNav = 0;
  int _currentBanner = 0;
  final _searchCtrl = TextEditingController();
  final _pageCtrl = PageController();
  final _scrollCtrl = ScrollController(); // ✅ Pour détecter la fin du scroll
  Timer? _bannerTimer; // ✅ Timer auto-scroll bannières

  @override
  void initState() {
    super.initState();
    Get.put(ProfileController());
    _menu = Get.put(HomeController());
    Get.put(FavoriteController());

    // ✅ Pagination : charge plus quand on approche la fin
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        _menu.loadMoreDishes();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  // ✅ Démarre l'auto-scroll des bannières une fois qu'elles sont chargées
  void _startBannerAutoScroll(int bannerCount) {
    _bannerTimer?.cancel();
    if (bannerCount <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageCtrl.hasClients) return;
      final next = (_currentBanner + 1) % bannerCount;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          _buildHomeBody(),
          CartScreen(onBack: () => setState(() => _selectedNav = 0)),
          FavoritesScreen(onBack: () => setState(() => _selectedNav = 0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Body principal ────────────────────────────────────────────────────────
  Widget _buildHomeBody() {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: _scrollCtrl, // ✅ Attaché au scroll controller
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
          Obx(() {
            if (_menu.dishesLoading.value && _menu.dishes.isEmpty) {
              return SliverToBoxAdapter(child: _buildDishesLoader());
            }
            final list = _menu.filteredDishes;
            if (list.isEmpty) {
              return SliverToBoxAdapter(child: _buildEmpty());
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildDishCard(list[i]),
                  childCount: list.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
              ),
            );
          }),
          // ✅ Indicateur de chargement en bas quand on charge plus
          Obx(
            () => SliverToBoxAdapter(
              child: _menu.isLoadingMore.value
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : const SizedBox(height: 30),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final profile = Get.find<ProfileController>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      child: Row(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () => setState(() => _selectedNav = 3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profile.profileImage.value != null
                      ? FileImage(profile.profileImage.value!)
                      : profile.avatarUrl.value != null
                      ? NetworkImage(profile.avatarUrl.value!) as ImageProvider
                      : const AssetImage(AppImages.onboardAsiatique),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    profile.fullName.value.isEmpty
                        ? 'Bienvenue 👋'
                        : profile.fullName.value,
                    style: AppTextStyles.greetingName.copyWith(
                      color: Colors.white,
                    ),
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
          Stack(
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
        ],
      ),
    );
  }

  // ── Bannières dynamiques avec auto-scroll ─────────────────────────────────
  Widget _buildBannerCarousel() {
    return Obx(() {
      if (_menu.bannersLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }

      final banners = _menu.banners;
      if (banners.isEmpty) return const SizedBox.shrink();

      // ✅ Démarre l'auto-scroll dès que les bannières sont disponibles
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _startBannerAutoScroll(banners.length),
      );

      return Column(
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemBuilder: (_, i) => _buildBannerItem(banners[i]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
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
    });
  }

  Widget _buildBannerItem(Map<String, dynamic> banner) {
    final title = banner['title'] as String;
    final image = banner['image'] as String?;
    final type = banner['type'] as String?;
    final actionLabel =
        (banner['action'] as Map<String, dynamic>?)?['label'] as String? ??
        'Voir';

    void onTap() {
      if (type == 'space') {
        Get.toNamed(AppRoutes.bookSpace);
      } else if (type == 'dishe') {
        Get.toNamed(AppRoutes.allProducts);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withOpacity(0.1),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.primary.withOpacity(0.15)),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (type == 'space')
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
                    if (type == 'space') const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: type == 'space'
                            ? Colors.white
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (type == 'product') ...[
                            const Icon(
                              CupertinoIcons.cart_badge_plus,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            actionLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: type == 'space'
                                  ? AppColors.secondary
                                  : Colors.white,
                            ),
                          ),
                        ],
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

  // ── Header catégories ─────────────────────────────────────────────────────
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

  // ── Chips catégories ──────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Obx(() {
      if (_menu.categoriesLoading.value && _menu.categories.isEmpty) {
        return SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => _shimmerChip(),
          ),
        );
      }
      final chips = [
        'Tous',
        ..._menu.categories.map((c) => c['name'] as String),
      ];
      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => Obx(() {
            final sel = _menu.selectedCategoryIndex.value == i;
            return GestureDetector(
              onTap: () => _menu.selectCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: sel
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
                  chips[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => _menu.searchQuery.value = v,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Rechercher un plat…',
          hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: Obx(
            () => _menu.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      _menu.searchQuery.value = '';
                    },
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.textGray,
                      size: 18,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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

  // ── Carte plat ────────────────────────────────────────────────────────────
  Widget _buildDishCard(Map<String, dynamic> dish) {
    final name = dish['name'] as String;
    final price = double.tryParse(dish['price'].toString()) ?? 0;
    final image = dish['image'] as String?;
    final isAvailable =
        dish['is_available'] == 1 || dish['is_available'] == true;
    final slug = dish['slug'] as String;
    final formatted = price.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), // ✅ remplace l'ancien RegExp
      (m) => ' ',
    );

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: slug),
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
                    // ✅ cacheWidth limite la résolution décodée → moins de RAM
                    child: image != null
                        ? Image.network(
                            image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Indisponible',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
                    name,
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
                      Text(
                        '$formatted FCFA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.badgeOff,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppColors.primary
                              : AppColors.textGray,
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _placeholder() => Container(
    color: AppColors.bgLight,
    child: Center(
      child: Icon(CupertinoIcons.photo, color: AppColors.textGray, size: 40),
    ),
  );

  Widget _shimmerChip() => Container(
    width: 90,
    height: 38,
    decoration: BoxDecoration(
      color: AppColors.divider,
      borderRadius: BorderRadius.circular(20),
    ),
  );

  Widget _buildDishesLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(height: 12, color: AppColors.divider),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 80, color: AppColors.divider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Center(
      child: Text(
        'Aucun plat dans cette catégorie',
        style: TextStyle(fontSize: 14, color: AppColors.textGray),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ── Bottom Nav ────────────────────────────────────────────────────────────
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
              final sel = _selectedNav == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedNav = i);
                  if (i == 2) Get.find<FavoriteController>().fetchFavorites();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: sel ? AppColors.primary : AppColors.textGray,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.primary : AppColors.textGray,
                        ),
                      ),
                      if (sel)
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
