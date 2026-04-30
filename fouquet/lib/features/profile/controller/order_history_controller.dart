import 'package:fouquet/features/profile/service/order_api_service.dart';
import 'package:get/get.dart';

class OrderHistoryController extends GetxController {
  // ── État ───────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt totalOrders = 0.obs;
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  // ── Cycle de vie ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    isLoading.value = true;
    hasError.value = false;

    final result = await OrderHistoryApiService.getOrderHistory();

    print('🔍 result: $result'); // ← ajoute cette ligne
    print('🔍 orders: ${result?['orders']}');

    if (result != null) {
      orders.assignAll(
        List<Map<String, dynamic>>.from(result['orders'] as List),
      );
      totalOrders.value = (result['total_orders'] as int?) ?? orders.length;
    } else {
      hasError.value = true;
    }

    isLoading.value = false;
  }

  // ── Filtrage par statut ────────────────────────────────────────────────────
  List<Map<String, dynamic>> filteredOrders(String tab) {
    if (tab == 'Tous') return orders.toList();
    return orders.where((o) => o['status_label'] == tab).toList();
  }
}
