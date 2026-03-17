import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _code = 'FOUQUET2024';

  final List<Map<String, String>> _reductions = const [
    {
      'title': '10% sur votre prochaine commande',
      'desc': 'Valable jusqu\'au 31/12/2024',
      'code': 'SAVE10',
    },
    {
      'title': 'Livraison offerte',
      'desc': 'Pour toute commande > 5 000 FCFA',
      'code': 'FREELIV',
    },
    {
      'title': '500 FCFA offerts',
      'desc': 'Sur votre 3e commande',
      'code': 'BONUS500',
    },
  ];

  final List<Map<String, String>> _history = const [
    {
      'name': 'Kofi A.',
      'date': '12 Jan 2024',
      'status': 'Validé',
      'points': '+200',
    },
    {
      'name': 'Amina B.',
      'date': '03 Mar 2024',
      'status': 'En attente',
      'points': '+0',
    },
    {
      'name': 'Yemi C.',
      'date': '21 Avr 2024',
      'status': 'Validé',
      'points': '+200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(),
            const SizedBox(height: 24),
            _buildCodeCard(context),
            const SizedBox(height: 28),
            _buildSectionTitle('Réductions disponibles'),
            const SizedBox(height: 12),
            ..._reductions.map((r) => _buildReductionItem(r)),
            const SizedBox(height: 28),
            _buildSectionTitle('Historique des parrainages'),
            const SizedBox(height: 12),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.bgLight,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Icon(
          CupertinoIcons.arrow_left,
          color: AppColors.textDark,
          size: 18,
        ), // ✅
      ),
    ),
    title: Text(
      'Parrainage & Réductions',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildPointsCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Text(
          'Vos points',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        const Text(
          '1 400 pts',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '≈ 1 400 FCFA de réduction',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _pointStat('7', 'Filleuls'),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(0.3),
            ),
            _pointStat('200 pts', 'Par filleul validé'),
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(0.3),
            ),
            _pointStat('3', 'Réductions utilisées'),
          ],
        ),
      ],
    ),
  );

  Widget _pointStat(String v, String l) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        l,
        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.75)),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildCodeCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre code de parrainage',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _code,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: _code));
                  Get.snackbar(
                    'Copié !',
                    'Code copié dans le presse-papiers',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    borderRadius: 14,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: Icon(
                  CupertinoIcons.doc_on_clipboard,
                  color: AppColors.primary,
                  size: 22,
                ), // ✅
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.share, size: 18), // ✅
            label: const Text('Partager avec des amis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  Widget _buildReductionItem(Map<String, String> r) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            CupertinoIcons.tag,
            color: AppColors.accent,
            size: 22,
          ), // ✅
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r['title']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                r['desc']!,
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            r['code']!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildHistoryList() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: List.generate(_history.length, (i) {
        final h = _history[i];
        final isValid = h['status'] == 'Validé';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isValid
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isValid
                          ? CupertinoIcons.checkmark_circle
                          : CupertinoIcons.clock, // ✅
                      color: isValid ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          h['date']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        h['points']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isValid ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(
                        h['status']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isValid ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (i < _history.length - 1)
              Divider(height: 1, indent: 66, color: AppColors.divider),
          ],
        );
      }),
    ),
  );
}
