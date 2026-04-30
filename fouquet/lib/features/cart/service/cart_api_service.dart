import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

class CartApiService {
  CartApiService._();

  static final HttpClient _client = HttpClient();

  // ─── Récupérer le panier ──────────────────────────────
  static Future<Map<String, dynamic>?> getCart() async {
    try {
      final Response response = await _client.get(
        '/cart',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data is Map && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Ajouter un article ───────────────────────────────
  static Future<bool> addToCart({
    required String disheId,
    required int quantity,
  }) async {
    try {
      final Response response = await _client.post(
        '/cart',
        data: {'dishe_id': disheId, 'quantity': quantity},
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data is Map && response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Article ajouté.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Mettre à jour la quantité ────────────────────────
  static Future<bool> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final Response response = await _client.put(
        '/cart/$itemId',
        data: {'quantity': quantity},
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data is Map && response.data['success'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Supprimer un article ─────────────────────────────
  static Future<bool> removeCartItem(String itemId) async {
    try {
      final Response response = await _client.delete(
        '/cart/$itemId',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data is Map && response.data['success'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─── Gestion des erreurs ──────────────────────────────
  static void _handleError(DioException e) {
    final data = e.response?.data;
    if (data is! Map) return;
    showErrorToast(
      'Erreur',
      description: data['message'] ?? 'Une erreur est survenue.',
    );
  }
}
