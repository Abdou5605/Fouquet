import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:talker/talker.dart';

class FavoriteService {
  final _http = HttpClient();
  final _talker = Talker();

  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // ── GET /api/favorites ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>?> getFavorites() async {
    try {
      final res = await _http.get(
        '/favorites',
        options: Options(extra: {'requiresAuth': true}),
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final favorites = data['data']['favorites'] as List;
        return List<Map<String, dynamic>>.from(favorites);
      }
      return null;
    } on DioException catch (e) {
      _handleError(e, context: 'getFavorites');
      return null;
    }
  }

  // ── DELETE /api/favorites/{favorite_id} ───────────────────────────────────
  Future<bool> removeFavorite(String favoriteId) async {
    try {
      final res = await _http.delete(
        '/favorites/$favoriteId',
        options: Options(extra: {'requiresAuth': true}),
      );
      final data = res.data as Map<String, dynamic>;
      return data['success'] == true;
    } on DioException catch (e) {
      _handleError(e, context: 'removeFavorite');
      return false;
    }
  }

  // ── Gestion erreurs ───────────────────────────────────────────────────────
  void _handleError(DioException e, {required String context}) {
    final status = e.response?.statusCode;
    _talker.error('❌ FavoriteService.$context — status: $status');
    switch (status) {
      case 404:
        showErrorToast(
          'Introuvable',
          description: 'La ressource demandée est introuvable.',
        );
        break;
      case 403:
        showErrorToast(
          'Accès refusé',
          description: 'Vous n\'avez pas accès à cette ressource.',
        );
        break;
      default:
        break;
    }
  }
}
