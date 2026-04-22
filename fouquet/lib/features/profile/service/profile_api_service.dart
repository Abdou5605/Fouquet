import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

class ProfileApiService {
  ProfileApiService._();

  static final HttpClient _client = HttpClient();

  // ─── Récupérer le profil ───────────────────────────────
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
          'firstname': firstname,
          'lastname':  lastname,
          'address':   address,
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
        filePath:  filePath,
        fieldName: 'avatar',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        showSuccessToast(
          response.data['message'] ?? 'Avatar mis à jour.',
        );
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
        showSuccessToast(
          response.data['message'] ?? 'Avatar supprimé.',
        );
        return response.data['data']['user'];
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ─── Gestion des erreurs ──────────────────────────────
  static void _handleError(DioException e) {
    final data = e.response?.data;
    showErrorToast(
      'Erreur',
      description: data?['message'] ?? 'Une erreur est survenue.',
    );
  }
}