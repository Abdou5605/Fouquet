import 'package:get/get.dart';
import 'package:fouquet/features/cart/service/cart_api_service.dart';

class CartController extends GetxController {
  // ── État ───────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxInt total = 0.obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxString rawCartId = ''.obs; // ← cart_id racine de la réponse API

  // ── Cycle de vie ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  int get totalItems => items.fold(0, (sum, i) => sum + (i['quantity'] as int));
  int get delivery => items.isEmpty ? 0 : 500;
  int get grandTotal => total.value + delivery;
  String get grandTotalFormatted => grandTotal.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ' ',
  );

  // ── Chargement ─────────────────────────────────────────────────────────────
  Future<void> fetchCart() async {
    isLoading.value = true;
    final result = await CartApiService.getCart();
    if (result != null) {
      rawCartId.value = result['cart_id'] as String? ?? '';
      items.assignAll(
        List<Map<String, dynamic>>.from(result['items'] as List? ?? []),
      );
      total.value = (result['total'] as num?)?.toInt() ?? 0;
    }
    isLoading.value = false;
  }

  // ── Ajouter ────────────────────────────────────────────────────────────────
  Future<void> addItem({required String disheId, int quantity = 1}) async {
    isUpdating.value = true;
    final success = await CartApiService.addToCart(
      disheId: disheId,
      quantity: quantity,
    );
    if (success) await fetchCart();
    isUpdating.value = false;
  }

  // ── Incrémenter ────────────────────────────────────────────────────────────
  Future<void> increment(int index) async {
    final item = items[index];
    final itemId = item['id'] as String;
    final newQty = (item['quantity'] as int) + 1;

    items[index] = {
      ...item,
      'quantity': newQty,
      'subtotal': (item['price'] as int) * newQty,
    };
    items.refresh();

    final success = await CartApiService.updateCartItem(
      itemId: itemId,
      quantity: newQty,
    );
    if (!success)
      await fetchCart();
    else
      _recalcTotal();
  }

  // ── Décrémenter / supprimer ────────────────────────────────────────────────
  Future<void> decrement(int index) async {
    final item = items[index];
    final itemId = item['id'] as String;
    final qty = item['quantity'] as int;

    if (qty <= 1) {
      await removeItem(index);
      return;
    }

    final newQty = qty - 1;
    items[index] = {
      ...item,
      'quantity': newQty,
      'subtotal': (item['price'] as int) * newQty,
    };
    items.refresh();

    final success = await CartApiService.updateCartItem(
      itemId: itemId,
      quantity: newQty,
    );
    if (!success)
      await fetchCart();
    else
      _recalcTotal();
  }

  // ── Supprimer ──────────────────────────────────────────────────────────────
  Future<void> removeItem(int index) async {
    final item = Map<String, dynamic>.from(items[index]);
    final itemId = item['id'] as String;

    items.removeAt(index);
    _recalcTotal();

    final success = await CartApiService.removeCartItem(itemId);
    if (!success) await fetchCart();
  }

  // ── Vider le panier ────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    final snapshot = List<Map<String, dynamic>>.from(items);
    items.clear();
    total.value = 0;
    rawCartId.value = '';

    for (final item in snapshot) {
      await CartApiService.removeCartItem(item['id'] as String);
    }
  }

  // ── Recalcul local du total ────────────────────────────────────────────────
  void _recalcTotal() {
    total.value = items.fold(
      0,
      (sum, i) => sum + ((i['subtotal'] as num?)?.toInt() ?? 0),
    );
  }
}
