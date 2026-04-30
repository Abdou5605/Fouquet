import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/favorite/controller/favorite_controller.dart';
import 'package:fouquet/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FavoritesScreen({super.key, this.onBack});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoriteController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<FavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ctrl.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.favorites.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: ctrl.fetchFavorites,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                          itemCount: ctrl.favorites.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _buildFavoriteCard(i),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () =>
                  widget.onBack != null ? widget.onBack!() : Get.back(),
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
              const Text(
                'Mes Favoris',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${ctrl.favorites.length} article${ctrl.favorites.length > 1 ? 's' : ''}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(int i) {
    final item = ctrl.favorites[i];
    final name = item['name'] as String;
    final ingredients = item['ingredients'] as String? ?? '';
    final price = double.tryParse(item['price'].toString()) ?? 0;
    final rating = (item['rating'] as num?)?.toDouble() ?? 0.0;
    final image = item['image'] as String?;
    final disheId = item['dishe_id'] as String;

    final formatted = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]} ',
    );

    // ✅ Cherche le slug dans allDishes via dishe_id
    void navigateToDetail() {
      final homeCtrl = Get.find<HomeController>();
      final dish = homeCtrl.allDishes.firstWhereOrNull(
        (d) => d['id'] == disheId,
      );
      if (dish != null) {
        Get.toNamed(AppRoutes.productDetail, arguments: dish['slug']);
      } else {
        // Fallback — si le plat n'est pas en mémoire
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir ce plat pour le moment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      }
    }

    return Dismissible(
      key: Key('fav-${item['favorite_id']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ctrl.removeFavorite(i),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          CupertinoIcons.heart_slash,
          color: Colors.white,
          size: 26,
        ),
      ),
      child: GestureDetector(
        onTap: navigateToDetail, // ✅ navigation correcte
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: image != null
                    ? Image.network(
                        image,
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      )
                    : _imgPlaceholder(),
              ),
              const SizedBox(width: 14),
              // ── Infos ──────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ctrl.removeFavorite(i),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ingredients,
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$formatted FCFA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.badgeOff,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              color: AppColors.star,
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => ctrl.addToCart(disheId, name),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.shopping_cart,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.heart,
              size: 56,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos plats préférés ici',
            style: TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => widget.onBack != null ? widget.onBack!() : Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Découvrir le menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 85,
    height: 85,
    color: AppColors.bgLight,
    child: const Icon(
      CupertinoIcons.photo,
      color: AppColors.textGray,
      size: 30,
    ),
  );
}
