import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

class NotificationApiService {
  NotificationApiService._();

  static final HttpClient _client = HttpClient();

  // ─── Récupérer les notifications ──────────────────────
  static Future<Map<String, dynamic>?> getNotifications({int page = 1}) async {
    try {
      final Response response = await _client.get(
        '/notifications',
        queryParameters: {'page': page},
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        return {'data': response.data['data'], 'meta': response.data['meta']};
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Marquer une notification comme lue ──────────────
  static Future<bool> markAsRead(String id) async {
    try {
      final Response response = await _client.post(
        '/notifications/$id/read',
        options: Options(extra: {'requiresAuth': true}),
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Marquer une notification comme non lue ──────────
  static Future<bool> markAsUnread(String id) async {
    try {
      final Response response = await _client.patch(
        '/notifications/$id/unread',
        options: Options(extra: {'requiresAuth': true}),
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Marquer toutes comme lues ────────────────────────
  static Future<bool> markAllAsRead() async {
    try {
      final Response response = await _client.patch(
        '/notifications/read-all',
        options: Options(extra: {'requiresAuth': true}),
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Toggle notifications activées/désactivées ────────
  static Future<bool?> toggleNotifications() async {
    try {
      final Response response = await _client.patch(
        '/user/notifications/toggle',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        return response.data['data']['notifications_enabled'] as bool;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Gestion des erreurs ──────────────────────────────
  static void _handleError(DioException e) {
    if (e.response?.statusCode == 404) return;
    final data = e.response?.data;
    final message = (data is Map) ? data['message'] : null;
    showErrorToast(
      'Erreur',
      description: message ?? 'Une erreur est survenue.',
    );
  }
}
