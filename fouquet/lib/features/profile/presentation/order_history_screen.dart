import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _tabs = ['Tous', 'En cours', 'Livré', 'Annulé'];

  // ── Helper Nunito ──────────────────────────────────────────────────────────
  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.0,
    double letterSpacing = 0.0,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#FQ-2401',
      'date': '12 Mar 2026 · 14:32',
      'items': ['King Burger x1', 'Pizza Fouquet x2'],
      'total': 19000,
      'status': 'Livré',
      'image': AppImages.viande,
    },
    {
      'id': '#FQ-2398',
      'date': '10 Mar 2026 · 19:10',
      'items': ['Shawarma Royal x1'],
      'total': 3000,
      'status': 'Annulé',
      'image': AppImages.frite,
    },
    {
      'id': '#FQ-2395',
      'date': '09 Mar 2026 · 12:05',
      'items': ['Salade Fouquet x1', 'King Burger x1'],
      'total': 11500,
      'status': 'En cours',
      'image': AppImages.raisin,
    },
    {
      'id': '#FQ-2390',
      'date': '07 Mar 2026 · 20:48',
      'items': ['Pizza Fouquet x1'],
      'total': 7500,
      'status': 'Livré',
      'image': AppImages.rizaugras,
    },
    {
      'id': '#FQ-2385',
      'date': '05 Mar 2026 · 13:22',
      'items': ['King Burger x2', 'Shawarma Royal x1'],
      'total': 11000,
      'status': 'Livré',
      'image': AppImages.viande,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    final tab = _tabs[_tabCtrl.index];
    if (tab == 'Tous') return _orders;
    return _orders.where((o) => o['status'] == tab).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _buildOrderCard(_filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.arrow_left,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Mes commandes',
              textAlign: TextAlign.center,
              style: _nunito(
                size: 20,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_orders.length} commandes',
              style: _nunito(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = _tabCtrl.index == i;
          return GestureDetector(
            onTap: () => _tabCtrl.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.badgeOff : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
              ),
              child: Text(
                _tabs[i],
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Carte commande ────────────────────────────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  order['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.bgLight,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['id'],
                          style: _nunito(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        _buildStatusBadge(status, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['date'],
                      style: _nunito(size: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (order['items'] as List).join(' · '),
                      style: _nunito(size: 12, color: AppColors.textMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: _nunito(size: 12, color: AppColors.textGray),
                  ),
                  Text(
                    '${order['total']} F CFA',
                    style: _nunito(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColors.badgeOff,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (status == 'Livré')
                    _actionBtn(
                      label: 'Reorder',
                      color: AppColors.textGray,
                      onTap: () {},
                    ),
                  if (status == 'En cours') ...[
                    _actionBtn(
                      label: 'Suivre',
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _actionBtn(
                      label: 'Annuler',
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                  ],
                  if (status == 'Annulé')
                    _actionBtn(
                      label: 'Reorder',
                      color: AppColors.textGray,
                      onTap: () {},
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Badge statut ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: _nunito(size: 11, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  // ── Bouton action ─────────────────────────────────────────────────────────
  Widget _actionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: _nunito(size: 12, weight: FontWeight.w700, color: color),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Livré':
        return const Color(0xFF22C55E);
      case 'En cours':
        return Colors.blueAccent;
      case 'Annulé':
        return AppColors.secondary;
      default:
        return AppColors.textGray;
    }
  }

  // ── État vide ─────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.doc_text,
              size: 52,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune commande',
            style: _nunito(
              size: 20,
              weight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos commandes apparaîtront ici',
            style: _nunito(size: 14, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}
