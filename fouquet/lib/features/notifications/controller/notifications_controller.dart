import 'package:fouquet/features/notifications/service/notification_service.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // ─── État ─────────────────────────────────────────────
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isMarkingAll = false.obs;

  // ─── Données ──────────────────────────────────────────
  final notifications = <Map<String, dynamic>>[].obs;
  final notificationsEnabled = true.obs;

  // ─── Pagination ───────────────────────────────────────
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  bool get hasMore => currentPage.value < lastPage.value;

  // ─── Computed ─────────────────────────────────────────
  int get unreadCount =>
      notifications.where((n) => n['is_read'] == false).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // ─── Charger les notifications ────────────────────────
  Future<void> fetchNotifications({bool reset = true}) async {
    try {
      if (reset) {
        isLoading.value = true;
        currentPage.value = 1;
      } else {
        if (!hasMore || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      }

      final result = await NotificationApiService.getNotifications(
        page: currentPage.value,
      );

      if (result != null) {
        final List list = result['data'] as List;
        final meta = result['meta'] as Map;
        lastPage.value = meta['last_page'] ?? 1;

        final mapped = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (reset) {
          notifications.assignAll(mapped);
        } else {
          notifications.addAll(mapped);
        }
      }
    } catch (e) {
      print('fetchNotifications error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ─── Charger plus (pagination) ────────────────────────
  Future<void> loadMore() async {
    await fetchNotifications(reset: false);
  }

  // ─── Marquer une comme lue ────────────────────────────
  Future<void> markAsRead(String id) async {
    final success = await NotificationApiService.markAsRead(id);
    if (success) {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index] = {...notifications[index], 'is_read': true};
        notifications.refresh();
      }
    }
  }

  // ─── Marquer une comme non lue ────────────────────────
  Future<void> markAsUnread(String id) async {
    final success = await NotificationApiService.markAsUnread(id);
    if (success) {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index] = {...notifications[index], 'is_read': false};
        notifications.refresh();
      }
    }
  }

  // ─── Toggle lu/non lu ─────────────────────────────────
  Future<void> toggleRead(String id) async {
    final notif = notifications.firstWhereOrNull((n) => n['id'] == id);
    if (notif == null) return;

    final isRead = notif['is_read'] as bool;
    if (isRead) {
      await markAsUnread(id);
    } else {
      await markAsRead(id);
    }
  }

  // ─── Marquer toutes comme lues ────────────────────────
  Future<void> markAllAsRead() async {
    isMarkingAll.value = true;
    final success = await NotificationApiService.markAllAsRead();
    if (success) {
      notifications.assignAll(
        notifications.map((n) => {...n, 'is_read': true}).toList(),
      );
    }
    isMarkingAll.value = false;
  }

  // ─── Toggle notifications on/off ──────────────────────
  Future<void> toggleNotifications() async {
    final result = await NotificationApiService.toggleNotifications();
    if (result != null) {
      notificationsEnabled.value = result;
    }
  }
}
