import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/features/profile/controller/order_history_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fouquet/core/style/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Les labels correspondent aux valeurs `status_label` renvoyées par l'API
  // plus "Tous" pour tout afficher.
  final _tabs = ['Tous', 'Confirmé', 'En attente', 'Annulé', 'Livré'];

  final OrderHistoryController _ctrl = Get.put(OrderHistoryController());

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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Body (loading / error / liste) ────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.badgeOff),
        );
      }

      if (_ctrl.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.wifi_slash,
                size: 48,
                color: AppColors.textGray,
              ),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger les commandes',
                style: _nunito(
                  size: 15,
                  weight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _ctrl.fetchOrderHistory,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeOff,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Réessayer',
                    style: _nunito(
                      size: 13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final filtered = _ctrl.filteredOrders(_tabs[_tabCtrl.index]);

      if (filtered.isEmpty) return _buildEmpty();

      return RefreshIndicator(
        color: AppColors.badgeOff,
        onRefresh: _ctrl.fetchOrderHistory,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => _buildOrderCard(filtered[i]),
        ),
      );
    });
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
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_ctrl.totalOrders.value} commandes',
                style: _nunito(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
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
    final status = order['status'] as String? ?? '';
    final statusLabel = order['status_label'] as String? ?? status;
    final statusColor = _statusColor(status);
    final reference = order['reference'] as String? ?? order['id'] ?? '—';
    final date = order['date'] as String? ?? '';
    final time = order['time'] as String? ?? '';
    final items = order['items'] as String? ?? '';
    final total = order['total'] as String? ?? '0.00';
    final actions = (order['actions'] as List?) ?? [];

    // Affiche la date et l'heure sur la même ligne
    final dateTime = [date, time].where((s) => s.isNotEmpty).join(' · ');

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
              // Placeholder image (l'API renvoie image: null pour l'instant)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.bag,
                  color: AppColors.textGray,
                  size: 30,
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
                          reference,
                          style: _nunito(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        _buildStatusBadge(statusLabel, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateTime,
                      style: _nunito(size: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      items,
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
                    '$total F CFA',
                    style: _nunito(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColors.badgeOff,
                    ),
                  ),
                ],
              ),
              // Boutons d'action provenant de l'API (liste d'actions dynamique)
              Row(
                children: [
                  if (actions.isNotEmpty)
                    ...actions.map<Widget>((action) {
                      final label = action['label'] as String? ?? '';
                      final actionColor = _actionColor(
                        action['type'] as String? ?? '',
                      );
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _actionBtn(
                          label: label,
                          color: actionColor,
                          onTap: () {
                            // TODO: implémenter les actions dynamiques
                          },
                        ),
                      );
                    }).toList()
                  else
                    // Fallback si l'API ne renvoie pas d'actions
                    ..._fallbackActions(status),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Actions de repli (basées sur le status brut) ──────────────────────────
  List<Widget> _fallbackActions(String status) {
    if (status == 'delivered' || status == 'confirmed') {
      return [
        _actionBtn(label: 'Reorder', color: AppColors.textGray, onTap: () {}),
      ];
    }
    if (status == 'pending') {
      return [
        _actionBtn(label: 'Suivre', color: AppColors.primary, onTap: () {}),
        const SizedBox(width: 8),
        _actionBtn(label: 'Annuler', color: AppColors.secondary, onTap: () {}),
      ];
    }
    if (status == 'cancelled') {
      return [
        _actionBtn(label: 'Reorder', color: AppColors.textGray, onTap: () {}),
      ];
    }
    return [];
  }

  // ── Badge statut ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String label, Color color) {
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
            label,
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

  // ── Couleur selon status brut ─────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'pending':
        return Colors.blueAccent;
      case 'cancelled':
        return AppColors.secondary;
      default:
        return AppColors.textGray;
    }
  }

  // ── Couleur selon type d'action ───────────────────────────────────────────
  Color _actionColor(String type) {
    switch (type) {
      case 'track':
        return AppColors.primary;
      case 'cancel':
        return AppColors.secondary;
      case 'reorder':
        return AppColors.textGray;
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
