import 'package:dio/dio.dart';
import 'package:fouquet/core/config/app_config.dart';
import 'package:fouquet/core/http/token_manager.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:talker/talker.dart';

class HttpClient {
  late Dio _dio;
  final TokenManager _tokenManager = TokenManager();
  final Talker talker = Talker();

  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;

  HttpClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
        // ✅ CORRECTION PRINCIPALE :
        // On laisse Dio lancer une DioException pour tout code >= 400
        // Chaque service gère ses propres erreurs 4xx avec des messages précis
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => talker.debug(obj),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // ============================================================================
  // INTERCEPTEURS
  // ============================================================================

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? false;

    if (requiresAuth) {
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        talker.info("✅ Token ajouté aux headers");
      } else {
        talker.warning("⚠️ Aucun token disponible");
      }
    }

    talker.debug("📤 ${options.method} ${options.path}");
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    talker.info(
      "✅ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}",
    );
    return handler.next(response);
  }

  /// Intercepteur d'erreurs — gère UNIQUEMENT les cas transversaux (401, 5xx, réseau)
  /// Les erreurs 422, 403, 404 sont gérées par chaque service individuellement
  /// pour afficher des messages précis et contextuels.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;
    final skipGlobal401 = error.requestOptions.extra["skipGlobal401"] == true;

    talker.error(
      "❌ Erreur ${statusCode ?? 'réseau'} ${error.requestOptions.method} ${error.requestOptions.path}",
    );

    // 401 — Session expirée (géré globalement sauf si désactivé)
    if (statusCode == 401 && !skipGlobal401) {
      await _handle401Unauthorized(error, handler);
      return;
    }

    // 5xx — Erreurs serveur (toujours affichées globalement)
    if (statusCode != null && statusCode >= 500) {
      showErrorToast(
        "Serveur indisponible",
        description:
            "Le service est momentanément indisponible. Réessayez dans quelques instants.",
      );
      return handler.next(error);
    }

    // Erreurs réseau (pas de réponse du serveur)
    if (error.response == null) {
      _handleNetworkErrors(error);
      return handler.next(error);
    }

    // Pour tout le reste (422, 403, 404…) : laisser remonter l'exception
    // vers le service concerné qui affichera un message précis et traduit.
    return handler.next(error);
  }

  // ============================================================================
  // GESTION SESSION / TOKEN
  // ============================================================================

  Future<void> _handle401Unauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    talker.warning("🔒 Session expirée (401 Unauthorized)");

    final canRetry = await _attemptTokenRefresh();

    if (canRetry) {
      try {
        final newRequest = error.requestOptions;
        final token = await _tokenManager.getAccessToken();
        if (token != null) {
          newRequest.headers['Authorization'] = 'Bearer $token';
          final clonedRequest = await _dio.fetch(newRequest);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        talker.error("❌ Erreur lors de la nouvelle tentative: $e");
      }
    }

    await _handleSessionExpired();
    return handler.next(error);
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final isExpired = await _tokenManager.isTokenExpired();
      if (!isExpired) {
        talker.info("ℹ️ Le token n'est pas encore expiré");
        return true;
      }
      talker.warning(
        "⚠️ Token expiré - Rafraîchissement impossible avec Sanctum",
      );
      return false;
    } catch (e) {
      talker.error("❌ Erreur lors du rafraîchissement du token: $e");
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    try {
      showWarningToast(
        "Session expirée",
        description: "Veuillez vous reconnecter",
      );
      await Future.delayed(const Duration(seconds: 2));
      await _tokenManager.clearTokens();
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      talker.error("❌ Erreur lors de la gestion de session expirée: $e");
    }
  }

  // ============================================================================
  // GESTION ERREURS RÉSEAU (sans réponse serveur)
  // ============================================================================

  void _handleNetworkErrors(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        showErrorToast(
          "Connexion trop lente",
          description:
              "Le serveur met trop de temps à répondre. Vérifiez votre réseau.",
        );
        break;
      case DioExceptionType.sendTimeout:
        showErrorToast(
          "Délai d'envoi dépassé",
          description: "L'envoi des données a pris trop de temps. Réessayez.",
        );
        break;
      case DioExceptionType.receiveTimeout:
        showErrorToast(
          "Délai de réception dépassé",
          description:
              "La réception des données a pris trop de temps. Réessayez.",
        );
        break;
      case DioExceptionType.badCertificate:
        showErrorToast(
          "Certificat invalide",
          description: "Problème de sécurité SSL. Contactez le support.",
        );
        break;
      case DioExceptionType.connectionError:
        showErrorToast(
          "Pas de connexion internet",
          description: "Vérifiez votre Wi-Fi ou vos données mobiles.",
        );
        break;
      case DioExceptionType.cancel:
        talker.info("ℹ️ Requête annulée");
        break;
      default:
        showErrorToast(
          "Erreur réseau",
          description:
              "Impossible de contacter le serveur. Vérifiez votre connexion.",
        );
    }
  }

  // ============================================================================
  // MÉTHODES HTTP
  // ============================================================================

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String url, {dynamic data, Options? options}) async {
    try {
      return await _dio.put(url, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String url, {dynamic data, Options? options}) async {
    try {
      return await _dio.patch(url, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String url, {dynamic data, Options? options}) async {
    try {
      return await _dio.delete(url, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadFile(
    String url, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        ...?additionalData,
      });
      return await _dio.post(
        url,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadMultipleFiles(
    String url, {
    required List<String> filePaths,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final files = await Future.wait(
        filePaths.map(
          (path) =>
              MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
      final formData = FormData.fromMap({fieldName: files, ...?additionalData});
      return await _dio.post(
        url,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  void cancelRequests([String? reason]) {
    _dio.close(force: true);
    talker.warning(
      "🚫 Toutes les requêtes annulées${reason != null ? ': $reason' : ''}",
    );
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    talker.info("🔄 Base URL mise à jour: $newBaseUrl");
  }

  void addGlobalHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void removeGlobalHeader(String key) {
    _dio.options.headers.remove(key);
  }
}
