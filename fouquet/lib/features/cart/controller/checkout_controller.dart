import 'package:fouquet/features/cart/service/checkout_api_service.dart';
import 'package:fouquet/features/profile/service/referral_api_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';

// ── Modèle promo (inline) ────────────────────────────────────────────────────
class PromoCode {
  final String id;
  final String code;
  final String description;
  final String typeReduction; // 'percentage' | 'fixed_amount'
  final double value;

  const PromoCode({
    required this.id,
    required this.code,
    required this.description,
    required this.typeReduction,
    required this.value,
  });

  factory PromoCode.fromJson(Map<String, dynamic> j) => PromoCode(
    id: j['id'] as String,
    code: j['code'] as String,
    description: j['description'] as String,
    typeReduction: j['type_reduction'] as String,
    value: double.parse(j['value'].toString()),
  );

  /// Réduction calculée selon le type
  double discountFor(double subtotal) {
    if (typeReduction == 'percentage') {
      return subtotal * (value / 100);
    } else {
      return value > subtotal ? subtotal : value;
    }
  }

  /// Label lisible pour l'UI
  String get label => typeReduction == 'percentage'
      ? '${value.toStringAsFixed(0)}% de réduction'
      : '${value.toStringAsFixed(0)} FCFA de réduction';
}

// ── États possibles du processus de commande ─────────────────────────────────
enum CheckoutStep { idle, preparing, awaitingProof, confirming, success, error }

class CheckoutController extends GetxController {
  // ── Dépendances ─────────────────────────────────────────────────────────────
  final _orderService = OrderService();
  final _cart = Get.find<CartController>();
  final _profile = Get.find<ProfileController>();
  final _picker = ImagePicker();

  // ── État de l'écran ──────────────────────────────────────────────────────────
  final step = CheckoutStep.idle.obs;
  final deliveryModeIndex = 0.obs;
  final deliveryCity = ''.obs;
  final deliveryDistrict = ''.obs;

  // ── Code promo ───────────────────────────────────────────────────────────────
  final promoApplied = false.obs;
  final promoLoading = false.obs;
  final promoError = RxnString();
  final promoCode = ''.obs;
  final appliedPromo = Rxn<PromoCode>(); // promo complète stockée

  // ── Résultats API ────────────────────────────────────────────────────────────
  final prepareResult = Rxn<PrepareOrderResult>();
  final confirmResult = Rxn<ConfirmOrderResult>();
  final proofImagePath = RxnString();

  // ── Getters ──────────────────────────────────────────────────────────────────
  bool get isDelivery => deliveryModeIndex.value == 0;
  bool get isLoading =>
      step.value == CheckoutStep.preparing ||
      step.value == CheckoutStep.confirming;
  String get cartId => _cart.rawCartId.value;

  // ── Calculs ──────────────────────────────────────────────────────────────────
  double get subtotal => _cart.total.value.toDouble();
  double get deliveryFee => isDelivery ? 500 : 0;
  double get discount => appliedPromo.value?.discountFor(subtotal) ?? 0;
  double get total => subtotal + deliveryFee - discount;

  // ── Cycle de vie ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _parseAddress(_profile.address.value);
  }

  void _parseAddress(String address) {
    final parts = address.split(',');
    deliveryCity.value = parts.isNotEmpty ? parts[0].trim() : '';
    deliveryDistrict.value = parts.length > 1 ? parts[1].trim() : '';
  }

  void updateAddress(String city, String district) {
    deliveryCity.value = city.trim();
    deliveryDistrict.value = district.trim();
  }

  void setDeliveryMode(int index) => deliveryModeIndex.value = index;

  // ── Code promo ───────────────────────────────────────────────────────────────
  Future<void> applyPromo(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    promoLoading.value = true;
    promoError.value = null;

    final list = await PromoCodeService.getPromoCodes();

    final match = list.cast<Map<String, dynamic>>().firstWhereOrNull(
      (p) => (p['code'] as String).toUpperCase() == trimmed,
    );

    if (match != null) {
      final promo = PromoCode.fromJson(match);
      appliedPromo.value = promo;
      promoApplied.value = true;
      promoCode.value = promo.code;
      promoError.value = null;
    } else {
      appliedPromo.value = null;
      promoApplied.value = false;
      promoCode.value = '';
      promoError.value = 'Code invalide ou expiré';
    }

    promoLoading.value = false;
  }

  void removePromo() {
    appliedPromo.value = null;
    promoApplied.value = false;
    promoCode.value = '';
    promoError.value = null;
  }

  // ── Étape 1 : Préparer la commande ──────────────────────────────────────────
  Future<void> prepareOrder() async {
    if (cartId.isEmpty) {
      await _cart.fetchCart();
      if (cartId.isEmpty) return;
    }

    step.value = CheckoutStep.preparing;

    final result = await _orderService.prepare(
      cartId: cartId,
      deliveryType: isDelivery ? 'delivery' : 'pickup',
      deliveryCity: deliveryCity.value,
      deliveryDistrict: deliveryDistrict.value,
      paymentMethod: 'mtn',
      promoCode: promoApplied.value ? promoCode.value : null,
    );

    if (result != null) {
      prepareResult.value = result;
      step.value = CheckoutStep.awaitingProof;
      await _launchUssd(result.momo.ussdLink);
    } else {
      step.value = CheckoutStep.idle;
    }
  }

  // ── Lancement USSD ───────────────────────────────────────────────────────────
  Future<void> _launchUssd(String ussdLink) async {
    try {
      // Garder le # brut (non encodé) pour Android
      final raw = ussdLink.replaceAll('%23', '#');
      final uri = Uri.parse(raw);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  // ── Preuve de paiement ───────────────────────────────────────────────────────
  Future<void> pickProofImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) proofImagePath.value = image.path;
  }

  Future<void> takeProofPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) proofImagePath.value = image.path;
  }

  // ── Étape 2 : Confirmer la commande ─────────────────────────────────────────
  Future<void> confirmOrder() async {
    final cacheKey = prepareResult.value?.cacheKey;
    final imagePath = proofImagePath.value;
    if (cacheKey == null || imagePath == null) return;

    step.value = CheckoutStep.confirming;

    final result = await _orderService.confirm(
      cacheKey: cacheKey,
      proofImagePath: imagePath,
    );

    if (result != null) {
      confirmResult.value = result;
      _cart.clearCart();
      step.value = CheckoutStep.success;
    } else {
      step.value = CheckoutStep.awaitingProof;
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────────
  void goHome() => Get.offAllNamed(AppRoutes.home);

  void resetToIdle() {
    step.value = CheckoutStep.idle;
    prepareResult.value = null;
    proofImagePath.value = null;
  }
}
