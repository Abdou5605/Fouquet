import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/main.dart'; // ✅ pour accéder à routeObserver
import 'package:google_fonts/google_fonts.dart';

// ✅ StatefulWidget + RouteAware
class CartScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CartScreen({super.key, this.onBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with RouteAware {
  late final CartController ctrl;

  // ── Helper Nunito ──────────────────────────────────────────────────────────
  static TextStyle _nunito({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color);

  static String _formatPrice(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ' ',
  );

  // ── Cycle de vie ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    ctrl = Get.put(CartController());
    ctrl.fetchCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Abonner cette page au routeObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // ✅ Appelé automatiquement quand on revient sur CartScreen
    ctrl.fetchCart();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.badgeOff),
            );
          }

          return Column(
            children: [
              _buildAppBar(ctrl),
              Expanded(
                child: ctrl.items.isEmpty
                    ? _buildEmptyCart(context)
                    : RefreshIndicator(
                        color: AppColors.badgeOff,
                        onRefresh: ctrl.fetchCart,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: [
                            ...List.generate(
                              ctrl.items.length,
                              (i) => _buildCartItem(context, ctrl, i),
                            ),
                            const SizedBox(height: 20),
                            _buildOrderSummary(ctrl),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(
        () => ctrl.items.isEmpty
            ? const SizedBox.shrink()
            : _buildBottomBar(context, ctrl),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(CartController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              // ✅ widget.onBack au lieu de onBack
              onTap: () => widget.onBack?.call(),
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
          ),
          Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mon Panier',
                  style: _nunito(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${ctrl.totalItems} article${ctrl.totalItems > 1 ? 's' : ''}',
                  style: _nunito(size: 13, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Obx(
            () => ctrl.items.isNotEmpty
                ? Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: ctrl.clearCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Vider',
                          style: _nunito(
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Item du panier ────────────────────────────────────────────────────────
  Widget _buildCartItem(BuildContext context, CartController ctrl, int i) {
    final item = ctrl.items[i];
    final name = item['name'] as String? ?? '';
    final price = (item['price'] as num?)?.toInt() ?? 0;
    final qty = (item['quantity'] as num?)?.toInt() ?? 1;
    final subtotal = (item['subtotal'] as num?)?.toInt() ?? price * qty;
    final imageUrl = item['image'] as String?;

    return Dismissible(
      key: Key(item['id'] as String),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ctrl.removeItem(i),
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 26),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$subtotal F',
                        style: _nunito(
                          size: 15,
                          weight: FontWeight.w800,
                          color: AppColors.badgeOff,
                        ),
                      ),
                      _buildQtySelector(ctrl, i, qty),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: AppColors.bgLight,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(
      CupertinoIcons.photo,
      color: AppColors.textGray,
      size: 30,
    ),
  );

  // ── Sélecteur de quantité ─────────────────────────────────────────────────
  Widget _buildQtySelector(CartController ctrl, int i, int qty) {
    return Row(
      children: [
        _QtyBtn(
          icon: CupertinoIcons.minus,
          onTap: () => ctrl.decrement(i),
          filled: false,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$qty',
            style: _nunito(
              size: 16,
              weight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        _QtyBtn(
          icon: CupertinoIcons.plus,
          onTap: () => ctrl.increment(i),
          filled: true,
        ),
      ],
    );
  }

  // ── Résumé de commande ────────────────────────────────────────────────────
  Widget _buildOrderSummary(CartController ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé',
              style: _nunito(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow('Sous-total', '${_formatPrice(ctrl.total.value)} F'),
            const SizedBox(height: 10),
            _summaryRow('Livraison', '${_formatPrice(ctrl.delivery)} F'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: _nunito(
                    size: 16,
                    weight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${_formatPrice(ctrl.grandTotal)} F',
                  style: _nunito(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.badgeOff,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _nunito(size: 14, color: AppColors.textGray)),
        Text(
          value,
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // ── Panier vide ───────────────────────────────────────────────────────────
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.badgeOff.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.shopping_cart,
              size: 56,
              color: AppColors.badgeOff,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Panier vide',
            style: _nunito(
              size: 22,
              weight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des plats depuis le menu',
            style: _nunito(size: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.allProducts),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.badgeOff,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Voir le menu',
                style: _nunito(
                  size: 15,
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

  // ── Barre de commande ─────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, CartController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.checkout),
        child: Obx(
          () => Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.badgeOff,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.badgeOff.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Commander ·${_formatPrice(ctrl.grandTotal)} F CFA',
                style: _nunito(
                  size: 16,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton quantité ───────────────────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? AppColors.badgeOff : AppColors.bgLight,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : AppColors.textDark,
          size: 16,
        ),
      ),
    );
  }
}
