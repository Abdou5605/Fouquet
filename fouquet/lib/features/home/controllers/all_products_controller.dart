import 'package:fouquet/features/home/controllers/home_controller.dart';
import 'package:fouquet/features/home/service/menu_service.dart';
import 'package:get/get.dart';

class AllProductsController extends GetxController {
  final _service = MenuService();

  // ── Plats ──────────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> dishes = <Map<String, dynamic>>[].obs;
  final RxBool dishesLoading = false.obs;
  int _dishPage = 1;
  bool _dishHasNext = true;

  // ── Sélection & recherche ──────────────────────────────────────────────────
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  // ── Catégories injectées depuis HomeController ─────────────────────────────
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool categoriesLoading = false.obs;

  List<Map<String, dynamic>> get filteredDishes {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return dishes;
    return dishes
        .where((d) => (d['name'] as String).toLowerCase().contains(q))
        .toList();
  }

  Map<String, dynamic>? get _selectedCategory =>
      selectedCategoryIndex.value == 0
          ? null
          : categories[selectedCategoryIndex.value - 1];

  @override
  void onInit() {
    super.onInit();
    _loadCategoriesFromMenu();
  }

  // ── Réutilise les catégories de HomeController ─────────────────────────────
  void _loadCategoriesFromMenu() {
    try {
      final menuCtrl = Get.find<HomeController>();
      categories.assignAll(menuCtrl.categories);

      if (categories.isEmpty) {
        categoriesLoading.value = true;
        ever(menuCtrl.categories, (list) {
          categories.assignAll(list as List<Map<String, dynamic>>);
          categoriesLoading.value = false;
          fetchAllDishes();
        });
      } else {
        fetchAllDishes();
      }
    } catch (_) {
      _fetchCategories().then((_) => fetchAllDishes());
    }
  }

  Future<void> _fetchCategories() async {
    categoriesLoading.value = true;
    final res = await _service.getCategories(page: 1);
    if (res != null && res['success'] == true) {
      categories.assignAll(List<Map<String, dynamic>>.from(res['data']));
    }
    categoriesLoading.value = false;
  }

  // ── Tous les plats (toutes catégories) ────────────────────────────────────
  Future<void> fetchAllDishes() async {
    dishes.clear();
    _dishPage = 1;
    _dishHasNext = false; // pas de pagination infinie sur "Tous"
    dishesLoading.value = true;

    for (final category in categories) {
      final res = await _service.getDishesByCategory(
        category['id'] as String,
        page: 1,
      );
      if (res != null && res['success'] == true) {
        dishes.addAll(List<Map<String, dynamic>>.from(res['data']));
      }
    }

    dishesLoading.value = false;
  }

  // ── Plats par catégorie ────────────────────────────────────────────────────
  Future<void> fetchDishesByCategory(
    String categoryId, {
    bool reset = false,
  }) async {
    if (!_dishHasNext && !reset) return;
    if (reset) {
      _dishPage = 1;
      _dishHasNext = true;
      dishes.clear();
    }
    dishesLoading.value = true;
    final res = await _service.getDishesByCategory(categoryId, page: _dishPage);
    if (res != null && res['success'] == true) {
      dishes.addAll(List<Map<String, dynamic>>.from(res['data']));
      final meta = res['meta'] as Map<String, dynamic>;
      _dishHasNext =
          (meta['current_page'] as int) < (meta['last_page'] as int);
      _dishPage++;
    }
    dishesLoading.value = false;
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  Future<void> loadMoreDishes() async {
    // "Tous" sélectionné → tout est déjà chargé, pas de pagination
    final cat = _selectedCategory;
    if (cat == null) return;
    if (_dishHasNext && !dishesLoading.value) {
      await fetchDishesByCategory(cat['id'] as String);
    }
  }

  // ── Sélection catégorie ────────────────────────────────────────────────────
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    searchQuery.value = '';
    if (index == 0) {
      fetchAllDishes();
    } else {
      fetchDishesByCategory(
        categories[index - 1]['id'] as String,
        reset: true,
      );
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectCategory(0);
  }
}