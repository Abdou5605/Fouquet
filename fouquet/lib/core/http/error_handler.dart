import 'package:dio/dio.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:talker/talker.dart';

class DioExceptionHandler {
  static final Talker _talker = Talker();

  /// Gère les exceptions Dio et retourne null
  static dynamic onDioException(DioException e) {
    try {
      _talker.error("🔴 Exception Dio: ${e.type}");

      if (e.response != null) {
        return _handleResponseError(e);
      } else {
        return _handleNetworkError(e);
      }
    } catch (error, stackTrace) {
      _talker.handle(error, stackTrace);
      showToast(title: "Une erreur inattendue s'est produite");
      return null;
    }
  }

  /// Gère les erreurs avec réponse du serveur
  static dynamic _handleResponseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    _talker.error("Erreur $statusCode: $data");

    switch (statusCode) {
      case 400:
        _showErrorMessage(data, "Requête invalide");
        break;

      case 401:
        _showErrorMessage(data, "Non autorisé");
        break;

      case 403:
        _showErrorMessage(data, "Accès refusé");
        break;

      case 404:
        _showErrorMessage(data, "Ressource introuvable");
        break;

      case 422:
        _handleValidationError(data);
        break;

      case 429:
        showToast(title: "Trop de requêtes. Veuillez patienter.");
        break;

      case 500:
      case 502:
      case 503:
        showToast(title: "Erreur serveur");
        break;

      default:
        _showErrorMessage(data, "Erreur inconnue ($statusCode)");
    }

    return null;
  }

  /// Gère les erreurs réseau (pas de réponse)
  static dynamic _handleNetworkError(DioException e) {
    _talker.error("Erreur réseau: ${e.message}");

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        showToast(
          title: "Délai de connexion dépassé",
          description: "Le serveur met trop de temps à répondre",
        );
        break;

      case DioExceptionType.sendTimeout:
        showToast(
          title: "Délai d'envoi dépassé",
          description: "L'envoi des données a pris trop de temps",
        );
        break;

      case DioExceptionType.receiveTimeout:
        showToast(
          title: "Délai de réception dépassé",
          description: "La réception des données a pris trop de temps",
        );
        break;

      case DioExceptionType.badCertificate:
        showToast(
          title: "Certificat invalide",
          description: "Problème de sécurité SSL",
        );
        break;

      case DioExceptionType.connectionError:
        showToast(
          title: "Erreur de connexion",
          description: "Vérifiez votre connexion internet",
        );
        break;

      case DioExceptionType.cancel:
        _talker.info("Requête annulée");
        break;

      default:
        showToast(
          title: "Erreur réseau",
          description: e.message ?? "Une erreur est survenue",
        );
    }

    return null;
  }

  /// Affiche un message d'erreur depuis les données de réponse
  static void _showErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data["message"] ?? fallback;
      showToast(title: message);
    } else if (data is String) {
      showToast(title: data);
    } else {
      showToast(title: fallback);
    }
  }

  /// Gère spécifiquement les erreurs de validation (422)
  static void _handleValidationError(dynamic data) {
    if (data is! Map<String, dynamic>) {
      showToast(title: "Erreur de validation");
      return;
    }

    final message = data["message"];
    final errors = data["errors"];

    if (errors != null && errors is Map<String, dynamic>) {
      // Récupérer tous les messages d'erreur
      final errorMessages = <String>[];

      errors.forEach((field, value) {
        if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      });

      if (errorMessages.isNotEmpty) {
        // Afficher le premier message
        showToast(
          title: "Erreur de validation",
          description: errorMessages.first,
        );
        return;
      }
    }

    showToast(title: message ?? "Erreur de validation");
  }
}

/// Fonction utilitaire pour une utilisation simple
dynamic onDioException(DioException e) {
  return DioExceptionHandler.onDioException(e);
}
