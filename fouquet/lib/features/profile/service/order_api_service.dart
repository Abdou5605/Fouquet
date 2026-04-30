import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

class OrderHistoryApiService {
  OrderHistoryApiService._();

  static final HttpClient _client = HttpClient();

  // ─── Récupérer l'historique des commandes ─────────────
  static Future<Map<String, dynamic>?> getOrderHistory() async {
    try {
      final Response response = await _client.get(
        '/orders/history',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        return {
          'orders': response.data['data'] as List<dynamic>,
          'total_orders': response.data['total_orders'],
        };
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Gestion des erreurs ──────────────────────────────
  static void _handleError(DioException e) {
    // Réponse HTML (404 Hostinger) ou data non-JSON → ignorer silencieusement
    if (e.response?.statusCode == 404) return;

    final data = e.response?.data;
    final message = (data is Map) ? data['message'] : null;
    showErrorToast(
      'Erreur',
      description: message ?? 'Une erreur est survenue.',
    );
  }
}
