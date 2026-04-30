import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

class ProfileApiService {
  ProfileApiService._();

  static final HttpClient _client = HttpClient();

  // ─── Récupérer le profil ──────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final Response response = await _client.get(
        '/auth/me',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        return response.data['data']['user'];
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Mettre à jour le profil ──────────────────────────
  static Future<Map<String, dynamic>?> updateProfile({
    required String firstname,
    required String lastname,
    required String address,
  }) async {
    try {
      final Response response = await _client.put(
        '/auth/profile',
        data: {
          'first_name': firstname,
          'last_name': lastname,
          'address': address,
        },
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        return response.data['data']['user'];
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Mettre à jour l'avatar ───────────────────────────
  static Future<Map<String, dynamic>?> updateAvatar({
    required String filePath,
  }) async {
    try {
      final Response response = await _client.uploadFile(
        '/auth/avatar',
        filePath: filePath,
        fieldName: 'avatar',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Avatar mis à jour.');
        return response.data['data']['user'];
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Supprimer l'avatar ───────────────────────────────
  static Future<Map<String, dynamic>?> deleteAvatar() async {
    try {
      final Response response = await _client.delete(
        '/auth/avatar',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Avatar supprimé.');
        return response.data['data']['user'];
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Supprimer le compte ──────────────────────────────
  static Future<bool> deleteAccount({required String password}) async {
    try {
      final Response response = await _client.delete(
        '/auth/delete-account',
        data: {'password': password},
        options: Options(extra: {'requiresAuth': true}),
      );
      if (response.data['success'] == true) {
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
    if (e.response?.statusCode == 404) return;
    final data = e.response?.data;
    final message = (data is Map) ? data['message'] : null;
    showErrorToast(
      'Erreur',
      description: message ?? 'Une erreur est survenue.',
    );
  }
}
