// ═══════════════════════════════════════════════════
// HELP CENTER SCREEN
// ═══════════════════════════════════════════════════
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'Comment passer une commande ?',
      'a':
          'Parcourez notre menu, ajoutez les plats souhaités au panier, puis validez votre commande en choisissant le mode de livraison et de paiement.',
    },
    {
      'q': 'Quels sont les délais de livraison ?',
      'a':
          'Nos délais de livraison sont généralement de 30 à 45 minutes selon votre localisation. Vous pouvez suivre votre commande en temps réel depuis l\'application.',
    },
    {
      'q': 'Comment annuler une commande ?',
      'a':
          'Vous pouvez annuler une commande dans les 5 minutes suivant sa validation depuis la page "Historique commandes". Au-delà, veuillez nous contacter directement.',
    },
    {
      'q': 'Quels modes de paiement sont acceptés ?',
      'a':
          'Nous acceptons les paiements par Mobile Money (MTN, Moov), carte bancaire, et en espèces à la livraison.',
    },
    {
      'q': 'Comment utiliser un code de réduction ?',
      'a':
          'Lors du passage de commande, entrez votre code promo dans le champ prévu à cet effet avant de valider le paiement.',
    },
    {
      'q': 'Que faire si ma commande est incorrecte ?',
      'a':
          'Contactez-nous immédiatement via la section "Nous contacter". Nous ferons le nécessaire pour corriger la situation dans les plus brefs délais.',
    },
    {
      'q': 'Comment modifier mon adresse de livraison ?',
      'a':
          'Rendez-vous dans "Modifier le profil" pour mettre à jour votre adresse principale, ou saisissez une adresse temporaire lors du passage de commande.',
    },
  ];

  List<Map<String, String>> get _filtered => _query.isEmpty
      ? _faqs
      : _faqs
            .where(
              (f) =>
                  f['q']!.toLowerCase().contains(_query.toLowerCase()) ||
                  f['a']!.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_query.isEmpty) ...[
                    _buildCategoryRow(),
                    const SizedBox(height: 28),
                  ],
                  _buildSectionTitle(
                    _query.isEmpty
                        ? 'Questions fréquentes'
                        : '${_filtered.length} résultat(s)',
                  ),
                  const SizedBox(height: 12),
                  if (_filtered.isEmpty)
                    _buildEmpty()
                  else
                    ..._filtered.asMap().entries.map(
                      (e) => _buildFaqItem(e.key, e.value),
                    ),
                ],
              ),
            ),
          ),
        ],
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
      'Centre d\'aide',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildSearchBar() => Container(
    color: AppColors.bgLight,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() {
        _query = v;
        _expandedIndex = null;
      }),
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Rechercher une question…',
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        prefixIcon: Icon(
          CupertinoIcons.search,
          color: AppColors.primary,
          size: 22,
        ), // ✅
        suffixIcon: _query.isNotEmpty
            ? GestureDetector(
                onTap: () => setState(() {
                  _searchCtrl.clear();
                  _query = '';
                }),
                child: Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.textGray,
                  size: 20,
                ), // ✅
              )
            : null,
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    ),
  );

  Widget _buildCategoryRow() {
    final cats = [
      {'icon': CupertinoIcons.bag, 'label': 'Commandes'},
      {'icon': CupertinoIcons.creditcard, 'label': 'Paiement'},
      {'icon': CupertinoIcons.car_detailed, 'label': 'Livraison'},
      {'icon': CupertinoIcons.person_circle, 'label': 'Compte'},
    ]; // ✅ tout Cupertino
    return Row(
      children: cats
          .map(
            (c) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: cats.indexOf(c) < cats.length - 1 ? 10 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Icon(
                      c['icon'] as IconData,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  Widget _buildFaqItem(int i, Map<String, String> faq) {
    final isOpen = _expandedIndex == i;
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isOpen ? null : i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? AppColors.primary : AppColors.divider,
            width: isOpen ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['q']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOpen ? AppColors.primary : AppColors.textDark,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      color: isOpen ? AppColors.primary : AppColors.textGray,
                      size: 18,
                    ), // ✅
                  ),
                ],
              ),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['a']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(CupertinoIcons.search, size: 48, color: AppColors.textGray), // ✅
          const SizedBox(height: 12),
          Text(
            'Aucun résultat pour "$_query"',
            style: TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
        ],
      ),
    ),
  );
}
