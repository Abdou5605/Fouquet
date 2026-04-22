import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FavoritesScreen({super.key, this.onBack});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> _favorites = [
    {
      'name': 'King Burger',
      'desc': 'Viande, œuf, fromage, laitue',
      'price': 4000,
      'image': AppImages.frite,
      'rating': 4.8,
    },
    {
      'name': 'Pizza Fouquet',
      'desc': 'Poulet fumé, champignon, mozza',
      'price': 7500,
      'image': AppImages.raisin,
      'rating': 4.9,
    },
    {
      'name': 'Shawarma Royal',
      'desc': 'Poulet, crevette, laitue, oignon',
      'price': 3000,
      'image': AppImages.viande,
      'rating': 4.7,
    },
    {
      'name': 'Panini Fouquet',
      'desc': 'Jambon, emmental, moza, tomate',
      'price': 4000,
      'image': AppImages.rizaugras,
      'rating': 4.5,
    },
  ];

  void _removeFavorite(int i) => setState(() => _favorites.removeAt(i));

  void _addToCart(String name) {
    Get.snackbar(
      'Ajouté au panier ✓',
      '$name a été ajouté à votre panier avec succès.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      icon: const Icon(
        CupertinoIcons.shopping_cart,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _favorites.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                      itemCount: _favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _buildFavoriteCard(i),
                    ),
            ),
          ],
        ),
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
                '${_favorites.length} plat${_favorites.length > 1 ? 's' : ''}',
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
    final item = _favorites[i];
    return Dismissible(
      key: Key('fav-$i-${item['name']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFavorite(i),
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
        onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: item),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  item['image'],
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 85,
                    height: 85,
                    color: AppColors.bgLight,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: AppColors.textGray,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ nom + cœur sur la même ligne, cœur à droite
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
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
                          onTap: () => _removeFavorite(i),
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
                      item['desc'],
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['price']} F',
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
                              '${item['rating']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _addToCart(item['name']),
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
}
