import 'package:flutter/material.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/favorite/service/favorite_api_service.dart';
import 'package:fouquet/features/home/controllers/home_controller.dart';
import 'package:fouquet/features/home/service/menu_service.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final _service = FavoriteService();
  final _menuService = MenuService();

  final RxList<Map<String, dynamic>> favorites = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  // ── Charger les favoris depuis l'API ──────────────────────────────────────
  Future<void> fetchFavorites() async {
    isLoading.value = true;
    final res = await _service.getFavorites();
    if (res != null) {
      favorites.assignAll(res);
    }
    isLoading.value = false;
  }

  // ✅ Supprime via toggle like — trouve le slug depuis allDishes
  Future<void> removeFavorite(int index) async {
    final item = favorites[index];
    final disheId = item['dishe_id'] as String;

    // Cherche le slug dans allDishes via dishe_id
    final homeCtrl = Get.find<HomeController>();
    final dish = homeCtrl.allDishes.firstWhereOrNull((d) => d['id'] == disheId);

    // Optimistic update
    favorites.removeAt(index);

    if (dish == null) {
      // Plat introuvable en mémoire → on retire juste visuellement
      return;
    }

    final slug = dish['slug'] as String;

    // Toggle like pour déliker
    final liked = await _menuService.likeDish(slug);

    if (liked == null) {
      // Erreur réseau → rollback
      favorites.insert(index, item);
    } else if (liked == true) {
      // A re-liké → rappelle pour déliker
      await _menuService.likeDish(slug);
    }
    // liked == false → déliké avec succès ✅
  }

  // ── Ajouter au panier ─────────────────────────────────────────────────────
  // APRÈS
  Future<void> addToCart(String disheId, String name) async {
    final cartCtrl = Get.find<CartController>();
    await cartCtrl.addItem(disheId: disheId);

    Get.snackbar(
      'Ajouté au panier ✓',
      '$name a été ajouté à votre panier.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
