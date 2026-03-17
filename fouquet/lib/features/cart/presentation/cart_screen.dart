import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBack; // ✅ callback pour retourner au home
  const CartScreen({super.key, this.onBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'King Burger',
      'desc': 'Viande, œuf, fromage, laitue',
      'price': 4000,
      'image': AppImages.rizaugras,
      'qty': 1,
    },
    {
      'name': 'Pizza Fouquet',
      'desc': 'Poulet fumé, champignon, mozza',
      'price': 7500,
      'image': AppImages.viande,
      'qty': 2,
    },
    {
      'name': 'Shawarma Royal',
      'desc': 'Poulet, crevette, laitue, oignon',
      'price': 3000,
      'image': AppImages.frite,
      'qty': 1,
    },
  ];

  final _promoCtrl = TextEditingController();

  int get _totalItems =>
      _cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));
  int get _subtotal => _cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] as int) * (item['qty'] as int),
  );
  int get _delivery => _cartItems.isEmpty ? 0 : 500;
  int get _total => _subtotal + _delivery;

  void _increment(int i) => setState(() => _cartItems[i]['qty']++);
  void _decrement(int i) {
    if (_cartItems[i]['qty'] > 1)
      setState(() => _cartItems[i]['qty']--);
    else
      _remove(i);
  }

  void _remove(int i) => setState(() => _cartItems.removeAt(i));

  @override
  void dispose() {
    _promoCtrl.dispose();
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
            Expanded(
              child: _cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        ...List.generate(
                          _cartItems.length,
                          (i) => _buildCartItem(i),
                        ),
                        const SizedBox(height: 16),
                        _buildCouponField(),
                        const SizedBox(height: 20),
                        _buildOrderSummary(),
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => widget.onBack?.call(), // ✅ retour via callback
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mon Panier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '$_totalItems article${_totalItems > 1 ? 's' : ''}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGray),
              ),
            ],
          ),
          if (_cartItems.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => setState(() => _cartItems.clear()),
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int i) {
    final item = _cartItems[i];
    return Dismissible(
      key: Key('$i-${item['name']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(i),
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
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.productDetail, arguments: item),
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
                child: Image.asset(
                  item['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.bgLight,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: AppColors.textGray,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['desc'],
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(item['price'] * item['qty']).toString()} F',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.badgeOff,
                          ),
                        ),
                        _buildQtySelector(i),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtySelector(int i) {
    return Row(
      children: [
        _QtyBtn(
          icon: CupertinoIcons.minus,
          onTap: () => _decrement(i),
          filled: false,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${_cartItems[i]['qty']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        _QtyBtn(
          icon: CupertinoIcons.plus,
          onTap: () => _increment(i),
          filled: true,
        ),
      ],
    );
  }

  Widget _buildCouponField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.tag, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _promoCtrl,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Entrez votre code promo ici…',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textGray),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Appliquer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
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
          const Text(
            'Résumé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow('Sous-total', '$_subtotal F'),
          const SizedBox(height: 10),
          _summaryRow('Livraison', '$_delivery F'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '$_total F',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.badgeOff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.textGray)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
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
          const Text(
            'Panier vide',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des plats depuis le menu',
            style: TextStyle(fontSize: 14, color: AppColors.textGray),
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
              child: const Text(
                'Voir le menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
        child: Container(
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
              'Commander · $_total F CFA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
