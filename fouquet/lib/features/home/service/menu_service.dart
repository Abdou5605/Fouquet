import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:talker/talker.dart';

class MenuService {
  final _http = HttpClient();
  final _talker = Talker();

  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  // ── GET /api/categories ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getCategories({int page = 1}) async {
    try {
      final res = await _http.get(
        '/categories',
        queryParameters: {'page': page},
        options: Options(extra: {'requiresAuth': true}),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, context: 'getCategories');
      return null;
    }
  }

  // ── GET /api/categories/{id}/dishes ──────────────────────────────────────
  Future<Map<String, dynamic>?> getDishesByCategory(
    String categoryId, {
    int page = 1,
    int perPage = 8, // ✅ Ajouté — 8 plats par défaut pour le lazy loading
  }) async {
    try {
      final res = await _http.get(
        '/categories/$categoryId/dishes',
        queryParameters: {
          'page': page,
          'per_page': perPage, // ✅ Envoyé à l'API
        },
        options: Options(extra: {'requiresAuth': true}),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, context: 'getDishesByCategory');
      return null;
    }
  }

  // ── GET /api/dishes/{slug} ────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getDishBySlug(String slug) async {
    try {
      final res = await _http.get(
        '/dishes/$slug',
        options: Options(extra: {'requiresAuth': true}),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, context: 'getDishBySlug');
      return null;
    }
  }

  // ── GET /api/banners ──────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>?> getBanners() async {
    try {
      final res = await _http.get('/banners');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return null;
    } on DioException catch (e) {
      _handleError(e, context: 'getBanners');
      return null;
    }
  }

  // ── POST /api/dishes/{slug}/like ──────────────────────────────────────────
  Future<bool?> likeDish(String slug) async {
    try {
      final res = await _http.post(
        '/dishes/$slug/like',
        options: Options(extra: {'requiresAuth': true}),
      );
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['liked'] as bool;
      }
      return null;
    } on DioException catch (e) {
      _handleError(e, context: 'likeDish');
      return null;
    }
  }

  // ── Gestion erreurs locale ────────────────────────────────────────────────
  void _handleError(DioException e, {required String context}) {
    final status = e.response?.statusCode;
    _talker.error('❌ MenuService.$context — status: $status');
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
      case 422:
        final errors = e.response?.data?['errors'];
        final msg = errors != null
            ? (errors as Map).values.first[0] as String
            : 'Données invalides.';
        showErrorToast('Erreur de validation', description: msg);
        break;
      default:
        break;
    }
  }
}
