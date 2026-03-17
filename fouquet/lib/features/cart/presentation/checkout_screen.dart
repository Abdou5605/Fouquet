import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryMode = 0;
  int _paymentMethod = 0;
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  bool _promoLoading = false;
  String? _promoError;
  bool _loading = false;

  final List<Map<String, dynamic>> _items = const [
    {'name': 'Poulet grillé', 'qty': 2, 'price': 3500},
    {'name': 'Riz sauté aux légumes', 'qty': 1, 'price': 2000},
    {'name': 'Jus de bissap', 'qty': 2, 'price': 800},
  ];

  double get _subtotal =>
      _items.fold(0, (sum, i) => sum + i['qty'] * i['price']);
  double get _delivery => _deliveryMode == 0 ? 500 : 0;
  double get _discount => _promoApplied ? _subtotal * 0.1 : 0;
  double get _total => _subtotal + _delivery - _discount;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() async {
    if (_promoCtrl.text.trim().isEmpty) return;
    setState(() {
      _promoLoading = true;
      _promoError = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _promoLoading = false;
      if (_promoCtrl.text.trim().toUpperCase() == 'SAVE10') {
        _promoApplied = true;
        _promoError = null;
      } else {
        _promoApplied = false;
        _promoError = 'Code invalide ou expiré';
      }
    });
  }

  void _confirm() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _loading = false);
    Get.toNamed(
      AppRoutes.payment,
      arguments: {
        'total': _total.toInt(),
        'items': _items.length,
        'deliveryMode': _deliveryMode == 0 ? 'Livraison' : 'À emporter',
        'paymentMethod': _paymentMethod,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Articles commandés'),
            const SizedBox(height: 12),
            _buildItemsList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Mode de livraison'),
            const SizedBox(height: 12),
            _buildDeliveryMode(),
            const SizedBox(height: 24),
            if (_deliveryMode == 0) ...[
              _buildSectionTitle('Adresse de livraison'),
              const SizedBox(height: 12),
              _buildAddressTile(),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Mode de paiement'),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildSectionTitle('Code promo'),
            const SizedBox(height: 12),
            _buildPromoField(),
            const SizedBox(height: 24),
            _buildSectionTitle('Résumé'),
            const SizedBox(height: 12),
            _buildPriceSummary(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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
      'Récapitulatif',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    ),
  );

  Widget _buildItemsList() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: List.generate(_items.length, (i) {
        final item = _items[i];
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'x${item['qty']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${(item['qty'] * item['price']).toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            if (i < _items.length - 1)
              Divider(height: 1, indent: 66, color: AppColors.divider),
          ],
        );
      }),
    ),
  );

  Widget _buildDeliveryMode() => Row(
    children: [
      _deliveryTile(
        0,
        CupertinoIcons.car_detailed,
        'Livraison',
        '+500 FCFA',
      ), // ✅
      const SizedBox(width: 12),
      _deliveryTile(1, CupertinoIcons.bag, 'À emporter', 'Gratuit'), // ✅
    ],
  );

  Widget _deliveryTile(int idx, IconData icon, String label, String sub) {
    final selected = _deliveryMode == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deliveryMode = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textGray,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? AppColors.primary : AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTile() => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.location,
              color: AppColors.primary,
              size: 22,
            ), // ✅
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Domicile',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Quartier Gbégamey, Cotonou',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.pencil, color: AppColors.textGray, size: 18), // ✅
        ],
      ),
    ),
  );

  Widget _buildPaymentMethods() {
    final methods = [
      {
        'label': 'MTN Mobile Money',
        'sub': 'MTN MoMo',
        'icon': CupertinoIcons.device_phone_portrait,
        'color': const Color(0xFFFFCC00),
      },
      {
        'label': 'Moov Money',
        'sub': 'Flooz',
        'icon': CupertinoIcons.device_phone_portrait,
        'color': const Color(0xFF0055A4),
      },
      {
        'label': 'Carte bancaire',
        'sub': 'Visa / Mastercard',
        'icon': CupertinoIcons.creditcard,
        'color': Colors.purple,
      },
      {
        'label': 'Espèces',
        'sub': 'À la livraison',
        'icon': CupertinoIcons.money_dollar_circle,
        'color': Colors.green,
      }, // ✅ tout Cupertino
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(methods.length, (i) {
          final m = methods[i];
          final selected = _paymentMethod == i;
          return Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _paymentMethod = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (m['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          m['icon'] as IconData,
                          color: m['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['label'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              m['sub'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 13,
                              )
                            : null, // ✅
                      ),
                    ],
                  ),
                ),
              ),
              if (i < methods.length - 1)
                Divider(height: 1, indent: 68, color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPromoField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoCtrl,
              enabled: !_promoApplied,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: 'Entrez votre code',
                hintStyle: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.tag,
                  color: _promoApplied ? Colors.green : AppColors.primary,
                  size: 20,
                ), // ✅
                filled: true,
                fillColor: AppColors.bgCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _promoApplied ? Colors.green : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.green, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _promoApplied
                ? () => setState(() {
                    _promoApplied = false;
                    _promoCtrl.clear();
                  })
                : _applyPromo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              width: 80,
              decoration: BoxDecoration(
                color: _promoApplied ? Colors.green : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _promoLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _promoApplied ? 'Retirer' : 'Appliquer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      if (_promoApplied)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.checkmark_circle,
                color: Colors.green,
                size: 16,
              ), // ✅
              const SizedBox(width: 6),
              Text(
                'Code appliqué — 10% de réduction !',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      if (_promoError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: AppColors.secondary,
                size: 16,
              ), // ✅
              const SizedBox(width: 6),
              Text(
                _promoError!,
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _buildPriceSummary() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: [
        _priceRow('Sous-total', '${_subtotal.toStringAsFixed(0)} FCFA'),
        const SizedBox(height: 10),
        _priceRow('Livraison', _deliveryMode == 0 ? '500 FCFA' : 'Gratuit'),
        if (_promoApplied) ...[
          const SizedBox(height: 10),
          _priceRow(
            'Réduction (10%)',
            '− ${_discount.toStringAsFixed(0)} FCFA',
            color: Colors.green,
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '${_total.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _priceRow(String label, String value, {Color? color}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 13, color: AppColors.textGray)),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textDark,
        ),
      ),
    ],
  );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    decoration: BoxDecoration(
      color: AppColors.bgLight,
      border: Border(top: BorderSide(color: AppColors.divider)),
    ),
    child: GestureDetector(
      onTap: _loading ? null : _confirm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: _loading
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _loading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Confirmer la commande',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${_total.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}
