import 'package:fouquet/features/home/service/menu_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final _service = MenuService();

  // ── Bannières ──────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> banners = <Map<String, dynamic>>[].obs;
  final RxBool bannersLoading = true.obs;

  // ── Catégories ─────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool categoriesLoading = true.obs;
  int _catPage = 1;
  bool _catHasNext = true;

  // ── Plats ──────────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> dishes = <Map<String, dynamic>>[].obs;
  final RxBool dishesLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // ── Pool complet (toutes catégories, pour pagination locale) ───────────────
  final List<Map<String, dynamic>> _allDishesPool = [];
  final RxList<Map<String, dynamic>> allDishes = <Map<String, dynamic>>[].obs;

  static const int _pageSize = 8; // ✅ 8 plats affichés à la fois
  int _displayedCount = 0; // combien sont actuellement affichés
  bool _poolLoaded = false; // pool entièrement chargé ?

  // ── Sélection & recherche ──────────────────────────────────────────────────
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  // ── Pagination par catégorie (mode catégorie sélectionnée) ────────────────
  int _dishPage = 1;
  bool _dishHasNext = true;

  Map<String, dynamic>? get _selectedCategory =>
      selectedCategoryIndex.value == 0
      ? null
      : categories[selectedCategoryIndex.value - 1];

  bool get hasMoreDishes => selectedCategoryIndex.value == 0
      ? (_displayedCount < _allDishesPool.length || !_poolLoaded)
      : _dishHasNext;

  List<Map<String, dynamic>> get filteredDishes {
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      return allDishes
          .where((d) => (d['name'] as String).toLowerCase().contains(q))
          .toList();
    }
    return dishes.toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchCategories().then((_) => _initAllDishes());
  }

  // ── Bannières ──────────────────────────────────────────────────────────────
  Future<void> fetchBanners() async {
    bannersLoading.value = true;
    final res = await _service.getBanners();
    if (res != null) banners.assignAll(res);
    bannersLoading.value = false;
  }

  // ── Catégories ─────────────────────────────────────────────────────────────
  Future<void> fetchCategories({bool reset = false}) async {
    if (!_catHasNext && !reset) return;
    if (reset) {
      _catPage = 1;
      _catHasNext = true;
      categories.clear();
    }
    categoriesLoading.value = true;
    final res = await _service.getCategories(page: _catPage);
    if (res != null && res['success'] == true) {
      categories.addAll(List<Map<String, dynamic>>.from(res['data']));
      final meta = res['meta'] as Map<String, dynamic>;
      _catHasNext = (meta['current_page'] as int) < (meta['last_page'] as int);
      _catPage++;
    }
    categoriesLoading.value = false;
  }

  Future<void> loadMoreCategories() async {
    if (_catHasNext && !categoriesLoading.value) await fetchCategories();
  }

  // ── Init mode "Tous" : charge le pool complet en arrière-plan ──────────────
  Future<void> _initAllDishes() async {
    _allDishesPool.clear();
    allDishes.clear();
    dishes.clear();
    _displayedCount = 0;
    _poolLoaded = false;
    dishesLoading.value = true;

    // Charge toutes les catégories en arrière-plan pour constituer le pool
    for (final category in categories) {
      int page = 1;
      bool hasNext = true;
      while (hasNext) {
        final res = await _service.getDishesByCategory(
          category['id'] as String,
          page: page,
        );
        if (res != null && res['success'] == true) {
          final data = List<Map<String, dynamic>>.from(res['data']);
          _allDishesPool.addAll(data);
          allDishes.addAll(data); // pour la recherche
          final meta = res['meta'] as Map<String, dynamic>?;
          if (meta != null) {
            hasNext =
                (meta['current_page'] as int) < (meta['last_page'] as int);
            page++;
          } else {
            hasNext = false;
          }
        } else {
          hasNext = false;
        }
      }
    }

    _poolLoaded = true;

    // ✅ Affiche uniquement les 8 premiers
    _displayedCount = _pageSize.clamp(0, _allDishesPool.length);
    dishes.assignAll(_allDishesPool.sublist(0, _displayedCount));

    dishesLoading.value = false;
  }

  // ── Plats par catégorie ────────────────────────────────────────────────────
  Future<void> fetchDishes(String categoryId, {bool reset = false}) async {
    if (!_dishHasNext && !reset) return;
    if (reset) {
      _dishPage = 1;
      _dishHasNext = true;
      dishes.clear();
    }
    dishesLoading.value = true;
    final res = await _service.getDishesByCategory(
      categoryId,
      page: _dishPage,
      perPage: _pageSize,
    );
    if (res != null && res['success'] == true) {
      dishes.addAll(List<Map<String, dynamic>>.from(res['data']));
      final meta = res['meta'] as Map<String, dynamic>;
      _dishHasNext = (meta['current_page'] as int) < (meta['last_page'] as int);
      _dishPage++;
    }
    dishesLoading.value = false;
  }

  // ── Charger plus au scroll ─────────────────────────────────────────────────
  Future<void> loadMoreDishes() async {
    if (isLoadingMore.value) return;

    final cat = _selectedCategory;

    if (cat == null) {
      // ── Mode "Tous" : on puise dans le pool local ──────────────────────────
      if (_displayedCount >= _allDishesPool.length) return;
      isLoadingMore.value = true;
      await Future.delayed(const Duration(milliseconds: 300)); // micro pause UX
      final next = (_displayedCount + _pageSize).clamp(
        0,
        _allDishesPool.length,
      );
      dishes.assignAll(_allDishesPool.sublist(0, next));
      _displayedCount = next;
      isLoadingMore.value = false;
    } else {
      // ── Mode catégorie : pagination API ───────────────────────────────────
      if (!_dishHasNext) return;
      isLoadingMore.value = true;
      await fetchDishes(cat['id'] as String);
      isLoadingMore.value = false;
    }
  }

  // ── Sélection catégorie ────────────────────────────────────────────────────
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    searchQuery.value = '';
    if (index == 0) {
      // Retour sur "Tous" : repart du pool depuis le début
      _displayedCount = _pageSize.clamp(0, _allDishesPool.length);
      dishes.assignAll(_allDishesPool.sublist(0, _displayedCount));
    } else {
      fetchDishes(categories[index - 1]['id'] as String, reset: true);
    }
  }
}
