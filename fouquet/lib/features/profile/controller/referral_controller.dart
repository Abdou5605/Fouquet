import 'package:fouquet/features/profile/service/referral_api_service.dart';
import 'package:get/get.dart';

class PromoCodeController extends GetxController {
  // ── Promos (/promo-codes) ─────────────────────────────────────────────────
  final isLoadingPromos = false.obs;
  final promoCodes = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  // ── Referral (/referral) ──────────────────────────────────────────────────
  final isLoadingReferral = false.obs;
  final referralData = Rxn<ReferralData>();

  bool get isLoading => isLoadingPromos.value || isLoadingReferral.value;

  // ── Getters raccourcis ────────────────────────────────────────────────────
  String get referralCode => referralData.value?.referralCode ?? '—';
  ReferralPoints? get points => referralData.value?.points;
  List<ReferralEntry> get referrals => referralData.value?.referrals ?? [];
  List<ReferralReward> get rewards => referralData.value?.rewards ?? [];

  // ── Filtre promos ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return promoCodes;
    return promoCodes.where((p) {
      final code = (p['code'] as String).toLowerCase();
      final desc = ((p['description'] ?? '') as String).toLowerCase();
      return code.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchPromoCodes(), fetchReferral()]);
  }

  Future<void> fetchPromoCodes() async {
    isLoadingPromos.value = true;
    final result = await PromoCodeService.getPromoCodes();
    promoCodes.assignAll(result);
    isLoadingPromos.value = false;
  }

  Future<void> fetchReferral() async {
    isLoadingReferral.value = true;
    final result = await ReferralService.getReferral();
    referralData.value = result;
    isLoadingReferral.value = false;
  }
}
