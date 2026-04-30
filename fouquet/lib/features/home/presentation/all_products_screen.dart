import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/home/controllers/all_products_controller.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late final AllProductsController _ctrl;
  final _searchCtrl = TextEditingController();

  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.0,
    TextDecoration? decoration,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    decoration: decoration,
  );

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(AllProductsController());
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
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    _ctrl.loadMoreDishes();
                  }
                  return false;
                },
                child: Obx(() {
                  // ✅ Loader uniquement si chargement en cours ET liste vide
                  if (_ctrl.dishesLoading.value && _ctrl.dishes.isEmpty) {
                    return _buildLoader();
                  }

                  final dishes = _ctrl.filteredDishes;

                  // ✅ Supprimé : if (selectedCategoryIndex == 0) return _buildHint()
                  // "Tous" charge vraiment les plats, on affiche la grille normalement
                  if (dishes.isEmpty && !_ctrl.dishesLoading.value) {
                    return _buildEmpty();
                  }

                  return _buildGrid(dishes);
                }),
              ),
            ),
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
          Obx(
            () => Column(
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
                  '${_ctrl.dishes.length} plats chargés',
                  style: _nunito(size: 13, color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => _ctrl.searchQuery.value = v,
        style: _nunito(size: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Rechercher un plat…',
          hintStyle: _nunito(size: 14, color: AppColors.textGray),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: Obx(
            () => _ctrl.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      _ctrl.searchQuery.value = '';
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

  // ── Chips catégories ──────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return Obx(() {
      if (_ctrl.categoriesLoading.value && _ctrl.categories.isEmpty) {
        return SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }
      final chips = [
        'Tous',
        ..._ctrl.categories.map((c) => c['name'] as String),
      ];
      return SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => Obx(() {
            final sel = _ctrl.selectedCategoryIndex.value == i;
            return GestureDetector(
              onTap: () => _ctrl.selectCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.divider,
                    width: 1.5,
                  ),
                  boxShadow: sel
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
                      i == 0
                          ? CupertinoIcons.square_grid_2x2
                          : CupertinoIcons.tag,
                      color: sel ? Colors.white : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chips[i],
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 10,
                        weight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  // ── Compteur résultats ────────────────────────────────────────────────────
  Widget _buildResultCount() {
    return Obx(() {
      final count = _ctrl.filteredDishes.length;
      final catIdx = _ctrl.selectedCategoryIndex.value;
      final catName = catIdx == 0
          ? 'Tous'
          : _ctrl.categories[catIdx - 1]['name'] as String;
      final q = _ctrl.searchQuery.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '$count plat${count > 1 ? 's' : ''}',
              style: _nunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.textGray,
              ),
            ),
            if (catName != 'Tous')
              Text(
                ' · $catName',
                style: _nunito(size: 13, color: AppColors.textGray),
              ),
            if (q.isNotEmpty) ...[
              Text(
                ' pour "',
                style: _nunito(size: 13, color: AppColors.textGray),
              ),
              Text(
                q,
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
    });
  }

  // ── Grille ────────────────────────────────────────────────────────────────
  Widget _buildGrid(List<Map<String, dynamic>> dishes) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      itemCount: dishes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) => _buildDishCard(dishes[i]),
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

    // ✅ Catégorie du plat lui-même, pas de la sélection courante
    final catName = dish['category']?['name'] as String? ?? '';

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
                    child: image != null
                        ? Image.network(
                            image,
                            width: double.infinity,
                            fit: BoxFit.cover,
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
                            style: _nunito(
                              size: 12,
                              weight: FontWeight.w700,
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
                    style: _nunito(
                      size: 13,
                      weight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (catName.isNotEmpty)
                    Text(
                      catName,
                      style: _nunito(size: 11, color: AppColors.textGray),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$formatted FCFA',
                        style: _nunito(
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppColors.badgeOff,
                        ),
                      ),
                      GestureDetector(
                        onTap: isAvailable
                            ? () async {
                                final disheId = dish['id'] as String?;
                                if (disheId == null) return;
                                final cartCtrl = Get.put(CartController());
                                await cartCtrl.addItem(disheId: disheId);
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
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.primary
                                : AppColors.textGray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.cart_badge_plus,
                            color: Colors.white,
                            size: 15,
                          ),
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

  Widget _placeholder() => Container(
    color: AppColors.bgLight,
    child: Center(
      child: Icon(CupertinoIcons.photo, color: AppColors.textGray, size: 40),
    ),
  );

  Widget _buildLoader() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.72,
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
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.search, size: 52, color: AppColors.textGray),
        const SizedBox(height: 16),
        Text(
          _ctrl.searchQuery.value.isNotEmpty
              ? 'Aucun résultat pour "${_ctrl.searchQuery.value}"'
              : 'Aucun plat dans cette catégorie',
          style: _nunito(size: 14, color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _searchCtrl.clear();
            _ctrl.resetFilters();
          },
          child: Text(
            'Réinitialiser',
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
