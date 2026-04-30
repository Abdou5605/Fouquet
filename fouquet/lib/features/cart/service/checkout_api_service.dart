import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';
import 'package:talker/talker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

int _toInt(dynamic v) => int.parse(v.toString().split('.').first);
double _toDouble(dynamic v) => double.parse(v.toString());

// ─────────────────────────────────────────────────────────────────────────────
// MODÈLES
// ─────────────────────────────────────────────────────────────────────────────

class MomoInfo {
  final String ussdCode;
  final String ussdLink;
  final int amount;
  final String label;

  const MomoInfo({
    required this.ussdCode,
    required this.ussdLink,
    required this.amount,
    required this.label,
  });

  factory MomoInfo.fromJson(Map<String, dynamic> json) => MomoInfo(
        ussdCode: json['ussd_code'] as String,
        ussdLink: json['ussd_link'] as String,
        amount:   _toInt(json['amount']),
        label:    json['label'] as String,
      );
}

class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final int subtotal;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name:      json['name'] as String,
        quantity:  _toInt(json['quantity']),
        unitPrice: _toDouble(json['unit_price']),
        subtotal:  _toInt(json['subtotal']),
      );
}

class PrepareOrderResult {
  final String cacheKey;
  final String deliveryType;
  final String deliveryCity;
  final String deliveryDistrict;
  final String paymentMethod;
  final int deliveryFee;
  final List<OrderItem> items;
  final int subtotal;
  final double discount;      // ✅ double car l'API renvoie "1500.00"
  final String? promoMessage;
  final int total;
  final String expiresIn;
  final MomoInfo momo;

  const PrepareOrderResult({
    required this.cacheKey,
    required this.deliveryType,
    required this.deliveryCity,
    required this.deliveryDistrict,
    required this.paymentMethod,
    required this.deliveryFee,
    required this.items,
    required this.subtotal,
    required this.discount,
    this.promoMessage,
    required this.total,
    required this.expiresIn,
    required this.momo,
  });

  factory PrepareOrderResult.fromJson(Map<String, dynamic> json) =>
      PrepareOrderResult(
        cacheKey:         json['cache_key']         as String,
        deliveryType:     json['delivery_type']     as String,
        deliveryCity:     json['delivery_city']     as String,
        deliveryDistrict: json['delivery_district'] as String,
        paymentMethod:    json['payment_method']    as String,
        deliveryFee:      _toInt(json['delivery_fee']),
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal:     _toInt(json['subtotal']),
        discount:     _toDouble(json['discount']),  // ✅ String "1500.00" → double
        promoMessage: json['promo_message'] as String?,
        total:        _toInt(json['total']),
        expiresIn:    json['expires_in'] as String,
        momo: MomoInfo.fromJson(json['momo'] as Map<String, dynamic>),
      );
}

class ConfirmOrderResult {
  final String orderId;
  final String reference;
  final String status;
  final int total;
  final String deliveryType;
  final String deliveryCity;
  final String deliveryDistrict;
  final String proofImageUrl;

  const ConfirmOrderResult({
    required this.orderId,
    required this.reference,
    required this.status,
    required this.total,
    required this.deliveryType,
    required this.deliveryCity,
    required this.deliveryDistrict,
    required this.proofImageUrl,
  });

  factory ConfirmOrderResult.fromJson(Map<String, dynamic> json) =>
      ConfirmOrderResult(
        orderId:          json['order_id']          as String,
        reference:        json['reference']         as String,
        status:           json['status']            as String,
        total:            _toInt(json['total']),
        deliveryType:     json['delivery_type']     as String,
        deliveryCity:     json['delivery_city']     as String,
        deliveryDistrict: json['delivery_district'] as String,
        proofImageUrl:    json['proof_image']       as String,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class OrderService {
  final HttpClient _http = HttpClient();
  final Talker _talker = Talker();

  static const _prepareEndpoint = '/orders/prepare';
  static const _confirmEndpoint = '/orders/confirm';

  // ── Étape 1 : préparer la commande ──────────────────────────────────────────
  Future<PrepareOrderResult?> prepare({
    required String cartId,
    required String deliveryType,
    required String deliveryCity,
    required String deliveryDistrict,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'cart_id': cartId,
        'delivery_type': deliveryType,
        'delivery_city': deliveryCity,
        'delivery_district': deliveryDistrict,
        'payment_method': paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
      };

      _talker.info('📦 OrderService.prepare → $body');

      final response = await _http.post(
        _prepareEndpoint,
        data: body,
        options: Options(extra: {'requiresAuth': true}),
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return PrepareOrderResult.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }

      showErrorToast(
        'Erreur',
        description: data['message'] as String? ?? 'Impossible de préparer la commande.',
      );
      return null;
    } on DioException catch (e) {
      _handleDioError(e, context: 'prepare');
      return null;
    } catch (e) {
      _talker.error('❌ OrderService.prepare unexpected: $e');
      showErrorToast('Erreur inattendue', description: e.toString());
      return null;
    }
  }

  // ── Étape 2 : confirmer la commande avec preuve de paiement ─────────────────
  Future<ConfirmOrderResult?> confirm({
    required String cacheKey,
    required String proofImagePath,
  }) async {
    try {
      _talker.info('✅ OrderService.confirm → cacheKey=$cacheKey');

      final formData = FormData.fromMap({
        'cache_key': cacheKey,
        'proof_image': await MultipartFile.fromFile(
          proofImagePath,
          filename: proofImagePath.split('/').last,
        ),
      });

      final response = await _http.post(
        _confirmEndpoint,
        data: formData,
        options: Options(
          extra: {'requiresAuth': true},
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return ConfirmOrderResult.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }

      showErrorToast(
        'Erreur',
        description: data['message'] as String? ?? 'Impossible de confirmer la commande.',
      );
      return null;
    } on DioException catch (e) {
      _handleDioError(e, context: 'confirm');
      return null;
    } catch (e) {
      _talker.error('❌ OrderService.confirm unexpected: $e');
      showErrorToast('Erreur inattendue', description: e.toString());
      return null;
    }
  }

  // ── Gestion des erreurs Dio ──────────────────────────────────────────────────
  void _handleDioError(DioException e, {required String context}) {
    final status = e.response?.statusCode;
    _talker.error('❌ OrderService.$context DioException $status: ${e.message}');

    switch (status) {
      case 400:
        final msg = _extractMessage(e.response?.data) ?? 'Données invalides.';
        showErrorToast('Commande invalide', description: msg);
        break;
      case 401:
        showWarningToast('Session expirée', description: 'Veuillez vous reconnecter.');
        break;
      case 403:
        showErrorToast('Accès refusé', description: 'Vous n\'avez pas accès à cette ressource.');
        break;
      case 404:
        showErrorToast('Introuvable', description: 'Le panier ou la commande est introuvable.');
        break;
      case 422:
        final msg = _extractValidationMessage(e.response?.data);
        showErrorToast('Validation échouée', description: msg);
        break;
      default:
        break;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }

  String _extractValidationMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      return data['message'] as String? ?? 'Veuillez vérifier les informations saisies.';
    }
    return 'Veuillez vérifier les informations saisies.';
  }
}