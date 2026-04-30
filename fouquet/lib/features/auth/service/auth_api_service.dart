import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart'; // ✅ import manquant
import 'package:fouquet/core/http/token_manager.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:fouquet/features/auth/controllers/login_controller.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

class AuthApiService {
  AuthApiService._();

  static final HttpClient _client = HttpClient();
  static final TokenManager _tokenManager = TokenManager();

  // ─── Register ─────────────────────────────────────────
  static Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final Response response = await _client.post(
        '/auth/register',
        data: {
          'first_name': firstname,
          'last_name': lastname,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.data['success'] == true) {
        showSuccessToast(
          response.data['message'] ?? 'Compte créé avec succès.',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'register');
      return false;
    }
  }

  // ─── Login ────────────────────────────────────────────
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(extra: {'skipGlobal401': true}),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = data['user'];
        final accessToken = data['access_token'];

        await _tokenManager.saveTokens(accessToken, user['created_at']);
        await _tokenManager.saveUserInfo(
          userId: user['id'],
          email: user['email'],
          name: user['full_name'],
          phone: user['phone'],
        );

        showSuccessToast(response.data['message'] ?? 'Connexion réussie.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'login');
      return false;
    }
  }

  // ─── Verify OTP ───────────────────────────────────────
  static Future<bool> verifyOtp({
    required String email,
    required String code,
    required String type,
  }) async {
    try {
      final Response response = await _client.post(
        '/auth/verify-otp',
        data: {'email': email, 'code': code, 'type': type},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = data['user'];
        final accessToken = data['access_token'];

        await _tokenManager.saveTokens(accessToken, user['created_at']);
        await _tokenManager.saveUserInfo(
          userId: user['id'],
          email: user['email'],
          name: user['full_name'],
          phone: user['phone'],
        );

        showSuccessToast(response.data['message'] ?? 'Email vérifié.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'verifyOtp');
      return false;
    }
  }

  // ─── Resend OTP ───────────────────────────────────────
  static Future<bool> resendOtp({
    required String email,
    required String type,
  }) async {
    try {
      final Response response = await _client.post(
        '/auth/resend-otp',
        data: {'email': email, 'type': type},
      );

      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Code OTP renvoyé.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'resendOtp');
      return false;
    }
  }

  // ─── Forgot Password ──────────────────────────────────
  static Future<bool> forgotPassword({required String email}) async {
    try {
      final Response response = await _client.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.data['success'] == true) {
        showSuccessToast(
          response.data['message'] ?? 'Code de réinitialisation envoyé.',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'forgotPassword');
      return false;
    }
  }

  // ─── Update Avatar ────────────────────────────────────
  static Future<bool> updateAvatar({required String filePath}) async {
    try {
      final Response response = await _client.uploadFile(
        '/auth/avatar',
        filePath: filePath,
        fieldName: 'avatar',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Avatar mis à jour.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'updateAvatar');
      return false;
    }
  }

  // ─── Delete Avatar ────────────────────────────────────
  static Future<bool> deleteAvatar() async {
    try {
      final Response response = await _client.delete(
        '/auth/avatar',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Avatar supprimé.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'deleteAvatar');
      return false;
    }
  }

  // ─── Change Password ──────────────────────────────────
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final Response response = await _client.put(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        showSuccessToast(response.data['message'] ?? 'Mot de passe modifié.');
        return true;
      }
      return false;
    } on DioException catch (e) {
      _handleAuthError(e, context: 'changePassword');
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────
  static Future<void> logout() async {
    await _tokenManager.clearTokens();
    // ✅ Supprime et recrée proprement le LoginController avant de naviguer
    Get.delete<LoginController>(force: true);

    Get.offAllNamed(AppRoutes.login);
  }

  // ─── Gestion des erreurs Auth ─────────────────────────
  static void _handleAuthError(DioException e, {required String context}) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (statusCode) {
      case 401:
        showErrorToast(
          'Identifiants incorrects',
          description: data?['message'] ?? 'Email ou mot de passe invalide.',
        );
        break;
      case 403:
        showErrorToast(
          'Accès refusé',
          description: data?['message'] ?? 'Vous n\'avez pas accès.',
        );
        break;
      case 404:
        showErrorToast(
          'Introuvable',
          description: data?['message'] ?? 'Ressource introuvable.',
        );
        break;
      case 422:
        _handleValidationError(data);
        break;
      default:
        showErrorToast(
          'Erreur',
          description: data?['message'] ?? 'Une erreur est survenue.',
        );
    }
  }

  // ─── Gestion erreurs de validation (422) ──────────────
  static void _handleValidationError(dynamic data) {
    if (data is! Map<String, dynamic>) {
      showErrorToast('Erreur de validation');
      return;
    }

    final errors = data['errors'];

    if (errors != null && errors is Map<String, dynamic>) {
      final firstError = errors.values.first;
      final message = firstError is List
          ? firstError.first.toString()
          : firstError.toString();

      showErrorToast('Erreur de validation', description: message);
      return;
    }

    showErrorToast(
      'Erreur de validation',
      description: data['message'] ?? 'Données invalides.',
    );
  }
}
