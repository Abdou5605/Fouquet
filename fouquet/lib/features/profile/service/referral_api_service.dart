import 'package:dio/dio.dart';
import 'package:fouquet/core/http/http_client.dart';
import 'package:fouquet/core/presentation/toast.dart';

// ── Modèles ───────────────────────────────────────────────────────────────────

class ReferralData {
  final String referralCode;
  final ReferralPoints points;
  final List<ReferralEntry> referrals;
  final List<ReferralReward> rewards;

  const ReferralData({
    required this.referralCode,
    required this.points,
    required this.referrals,
    required this.rewards,
  });

  factory ReferralData.fromJson(Map<String, dynamic> j) => ReferralData(
    referralCode: j['referral_code'] as String,
    points: ReferralPoints.fromJson(j['points'] as Map<String, dynamic>),
    referrals: (j['referrals'] as List)
        .map((e) => ReferralEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    rewards: (j['rewards'] as List)
        .map((e) => ReferralReward.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ReferralPoints {
  final int total;
  final int equivalentFcfa;
  final int filleuls;
  final int pointsParFilleul;
  final int reductionsUtilisees;

  const ReferralPoints({
    required this.total,
    required this.equivalentFcfa,
    required this.filleuls,
    required this.pointsParFilleul,
    required this.reductionsUtilisees,
  });

  factory ReferralPoints.fromJson(Map<String, dynamic> j) => ReferralPoints(
    total: j['total'] as int,
    equivalentFcfa: j['equivalent_fcfa'] as int,
    filleuls: j['filleuls'] as int,
    pointsParFilleul: j['points_par_filleul'] as int,
    reductionsUtilisees: j['reductions_utilisees'] as int,
  );
}

class ReferralEntry {
  final String id;
  final String name;
  final String status; // 'validated' | 'pending'
  final int points;
  final String referralDate;

  const ReferralEntry({
    required this.id,
    required this.name,
    required this.status,
    required this.points,
    required this.referralDate,
  });

  bool get isValidated => status == 'validated';

  factory ReferralEntry.fromJson(Map<String, dynamic> j) => ReferralEntry(
    id: j['id'] as String,
    name: j['name'] as String,
    status: j['status'] as String,
    points: j['points'] as int,
    referralDate: j['referral_date'] as String,
  );
}

class ReferralReward {
  final String id;
  final String title;
  final String code;
  final String formattedValue;
  final String rewardDate;

  const ReferralReward({
    required this.id,
    required this.title,
    required this.code,
    required this.formattedValue,
    required this.rewardDate,
  });

  factory ReferralReward.fromJson(Map<String, dynamic> j) => ReferralReward(
    id: j['id'] as String,
    title: j['title'] as String,
    code: j['code'] as String,
    formattedValue: j['formatted_value'] as String,
    rewardDate: j['reward_date'] as String,
  );
}

// ── Services ──────────────────────────────────────────────────────────────────

class PromoCodeService {
  PromoCodeService._();
  static final _client = HttpClient();

  static Future<List<Map<String, dynamic>>> getPromoCodes() async {
    try {
      final res = await _client.get(
        '/promo-codes',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (res.data['success'] == true) {
        return List<Map<String, dynamic>>.from(res.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      final data = e.response?.data;
      showErrorToast(
        'Erreur',
        description:
            (data is Map ? data['message'] : null) ??
            'Une erreur est survenue.',
      );
      return [];
    }
  }
}

class ReferralService {
  ReferralService._();
  static final _client = HttpClient();

  static Future<ReferralData?> getReferral() async {
    try {
      final res = await _client.get(
        '/referral',
        options: Options(extra: {'requiresAuth': true}),
      );
      if (res.data['success'] == true) {
        return ReferralData.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      showErrorToast(
        'Erreur',
        description:
            (data is Map ? data['message'] : null) ??
            'Une erreur est survenue.',
      );
      return null;
    }
  }
}
