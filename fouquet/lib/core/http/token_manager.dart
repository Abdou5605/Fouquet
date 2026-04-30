import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class TokenManager {
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _expiresAt = 'EXPIRY_DATE';
  static const _userIdKey = 'USER_ID';
  static const _userEmailKey = 'USER_EMAIL';
  static const _userNameKey = 'USER_NAME';
  static const _userRoleKey = 'USER_ROLE';
  static const _userPhoneKey = 'USER_PHONE';
  static const _createdAtKey = 'CREATED_AT';

  final Talker _talker = Talker();

  /// Sauvegarder les tokens
  Future<void> saveTokens(String accessToken, String expiryDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_expiresAt, expiryDate);
      _talker.info("✅ Tokens sauvegardés avec succès");
    } catch (e) {
      _talker.error("❌ Erreur lors de la sauvegarde des tokens: $e");
      rethrow;
    }
  }

  /// Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);
      if (token == null) _talker.warning("⚠️ Aucun token trouvé");
      return token;
    } catch (e) {
      _talker.error("❌ Erreur lors de la récupération du token: $e");
      return null;
    }
  }

  /// Récupérer la date d'expiration
  Future<String?> getExpiryDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_expiresAt);
    } catch (e) {
      _talker.error(
        "❌ Erreur lors de la récupération de la date d'expiration: $e",
      );
      return null;
    }
  }

  /// Vérifier si le token est expiré
  Future<bool> isTokenExpired() async {
    try {
      final expiryDate = await getExpiryDate();
      if (expiryDate == null) return true;
      final expiry = DateTime.tryParse(expiryDate);
      if (expiry == null) return true;
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      _talker.error("❌ Erreur lors de la vérification de l'expiration: $e");
      return true;
    }
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    return !(await isTokenExpired());
  }

  /// Sauvegarder les informations utilisateur
  Future<void> saveUserInfo({
    required String userId,
    required String email,
    String? name,
    String? role,
    String? phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      if (name != null) await prefs.setString(_userNameKey, name);
      if (role != null) await prefs.setString(_userRoleKey, role);
      if (phone != null) await prefs.setString(_userPhoneKey, phone);
      _talker.info("💾 Informations utilisateur sauvegardées");
    } catch (e) {
      _talker.error("❌ Erreur lors de la sauvegarde des infos utilisateur: $e");
    }
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Récupérer l'email utilisateur
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Récupérer le nom utilisateur
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Récupérer le rôle utilisateur
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Récupérer le téléphone utilisateur
  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  // ── Trial & Abonnement ────────

  /// Sauvegarder la date d'inscription (created_at)
  Future<void> saveCreatedAt(String createdAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_createdAtKey, createdAt);
      _talker.info("💾 created_at sauvegardé: $createdAt");
    } catch (e) {
      _talker.error("❌ Erreur sauvegarde created_at: $e");
    }
  }

  /// Récupérer la date d'inscription
  Future<String?> getUserCreatedAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_createdAtKey);
    } catch (e) {
      _talker.error("❌ Erreur récupération created_at: $e");
      return null;
    }
  }

  /// Nettoyer tous les tokens et infos
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_expiresAt);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_createdAtKey);
      _talker.info("🗑️ Tokens et infos utilisateur nettoyés avec succès");
    } catch (e) {
      _talker.error("❌ Erreur lors du nettoyage des tokens: $e");
      rethrow;
    }
  }

  /// Effacer toutes les données
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _talker.info("🗑️ Toutes les données nettoyées");
    } catch (e) {
      _talker.error("❌ Erreur lors du nettoyage complet: $e");
    }
  }
}
