import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/cart/controller/checkout_controller.dart';
import 'package:fouquet/features/cart/service/checkout_api_service.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injection du controller (doit être enregistré dans le binding ou ici)
    final ctrl = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: Obx(() {
        // ── Étape : preuve de paiement MoMo ──────────────────────────────────
        if (ctrl.step.value == CheckoutStep.awaitingProof) {
          return _MomoProofSheet(ctrl: ctrl);
        }

        // ── Étape : succès ────────────────────────────────────────────────────
        if (ctrl.step.value == CheckoutStep.success) {
          return _SuccessView(ctrl: ctrl);
        }

        // ── Étape : formulaire principal ──────────────────────────────────────
        return _CheckoutForm(ctrl: ctrl);
      }),
      bottomNavigationBar: Obx(() {
        if (ctrl.step.value == CheckoutStep.awaitingProof ||
            ctrl.step.value == CheckoutStep.success) {
          return const SizedBox.shrink();
        }
        return _BottomBar(ctrl: ctrl);
      }),
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
        ),
      ),
    ),
    title: Text(
      'Récapitulatif',
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMULAIRE PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutForm extends StatefulWidget {
  final CheckoutController ctrl;
  const _CheckoutForm({required this.ctrl});

  @override
  State<_CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<_CheckoutForm> {
  final _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Articles commandés'),
          const SizedBox(height: 12),
          _ItemsList(ctrl: ctrl),
          const SizedBox(height: 24),
          _sectionTitle('Mode de livraison'),
          const SizedBox(height: 12),
          _DeliveryMode(ctrl: ctrl),
          const SizedBox(height: 24),
          _AddressSection(ctrl: ctrl),
          _sectionTitle('Mode de paiement'),
          const SizedBox(height: 12),
          _buildPaymentMethod(),
          const SizedBox(height: 24),
          _sectionTitle('Code promo'),
          const SizedBox(height: 12),
          _PromoField(ctrl: ctrl, promoCtrl: _promoCtrl),
          const SizedBox(height: 24),
          _sectionTitle('Résumé'),
          const SizedBox(height: 12),
          _PriceSummary(ctrl: ctrl),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary, width: 1.5),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.device_phone_portrait,
            color: Color(0xFFFFCC00),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MTN Mobile Money',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'MTN MoMo Pay',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(
            CupertinoIcons.checkmark,
            color: Colors.white,
            size: 13,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS RÉUTILISABLES
// ─────────────────────────────────────────────────────────────────────────────

Widget _sectionTitle(String t) => Text(
  t,
  style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  ),
);

String _fmt(double amount) {
  final str = amount.toStringAsFixed(0);
  final buf = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write('\u00A0');
    buf.write(str[i]);
    count++;
  }
  return '${buf.toString().split('').reversed.join()} FCFA';
}

// ── Liste des articles ─────────────────────────────────────────────────────────

class _ItemsList extends StatelessWidget {
  final CheckoutController ctrl;
  const _ItemsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.prepareResult.value?.items ?? _cartItems(ctrl);
      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: Text(
              'Panier vide',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            String name;
            int qty;
            int subtotal;

            if (item is OrderItem) {
              name = item.name;
              qty = item.quantity;
              subtotal = item.subtotal;
            } else {
              // fallback cart map
              final map = item as Map<String, dynamic>;
              name = map['dishe']?['name'] ?? map['name'] ?? '—';
              qty = map['quantity'] as int? ?? 0;
              subtotal = (map['subtotal'] as num?)?.toInt() ?? 0;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                            'x$qty',
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
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        _fmt(subtotal.toDouble()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Divider(height: 1, indent: 66, color: AppColors.divider),
              ],
            );
          }),
        ),
      );
    });
  }

  List<dynamic> _cartItems(CheckoutController ctrl) {
    return Get.find<CartController>().items;
  }
}

// ── Mode de livraison ──────────────────────────────────────────────────────────

class _DeliveryMode extends StatelessWidget {
  final CheckoutController ctrl;
  const _DeliveryMode({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _tile(0, CupertinoIcons.car_detailed, 'Livraison', '+500 FCFA'),
          const SizedBox(width: 12),
          _tile(1, CupertinoIcons.bag, 'À emporter', 'Gratuit'),
        ],
      ),
    );
  }

  Widget _tile(int idx, IconData icon, String label, String sub) {
    final selected = ctrl.deliveryModeIndex.value == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.setDeliveryMode(idx),
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
}

// ── Section adresse (gère sa propre réactivité) ──────────────────────────────────

class _AddressSection extends StatelessWidget {
  final CheckoutController ctrl;
  const _AddressSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.deliveryModeIndex.value != 0) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Adresse de livraison'),
          const SizedBox(height: 12),
          _AddressTile(ctrl: ctrl),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}

// ── Adresse ────────────────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  final CheckoutController ctrl;
  const _AddressTile({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final city = ctrl.deliveryCity.value;
      final district = ctrl.deliveryDistrict.value;
      final display = [city, district].where((s) => s.isNotEmpty).join(', ');

      return Container(
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display.isNotEmpty ? display : 'Aucune adresse',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showAddressSheet(context, ctrl),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.pencil,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showAddressSheet(BuildContext context, CheckoutController ctrl) {
    final cityCtrl = TextEditingController(text: ctrl.deliveryCity.value);
    final districtCtrl = TextEditingController(
      text: ctrl.deliveryDistrict.value,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // ← indispensable pour que le sheet remonte
      builder: (sheetContext) => Padding(
        // ✅ viewInsets ici, dans le builder, pas dans le parent
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              _addressField(cityCtrl, 'Ville', 'Ex : Cotonou'),
              const SizedBox(height: 12),
              _addressField(districtCtrl, 'Quartier', 'Ex : Gbégamey'),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final city = cityCtrl.text.trim();
                  final district = districtCtrl.text.trim();

                  // ✅ Validation avant de fermer
                  if (city.isEmpty || district.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez renseigner la ville et le quartier.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return; // ← ne pas fermer le sheet
                  }

                  ctrl.updateAddress(city, district);
                  Navigator.pop(sheetContext);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Confirmer l'adresse",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressField(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
            prefixIcon: const Icon(
              CupertinoIcons.location,
              color: AppColors.primary,
              size: 18,
            ),
            filled: true,
            fillColor: AppColors.bgCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Code promo ─────────────────────────────────────────────────────────────────

class _PromoField extends StatelessWidget {
  final CheckoutController ctrl;
  final TextEditingController promoCtrl;
  const _PromoField({required this.ctrl, required this.promoCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final applied = ctrl.promoApplied.value;
      final loading = ctrl.promoLoading.value;
      final error = ctrl.promoError.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: promoCtrl,
                  enabled: !applied,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Entrez votre code',
                    hintStyle: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.tag,
                      color: applied ? Colors.green : AppColors.primary,
                      size: 20,
                    ),
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
                        color: applied ? Colors.green : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: applied
                    ? () {
                        ctrl.removePromo();
                        promoCtrl.clear();
                      }
                    : () => ctrl.applyPromo(promoCtrl.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  width: 80,
                  decoration: BoxDecoration(
                    color: applied ? Colors.green : AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            applied ? 'Retirer' : 'Appliquer',
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
          if (applied)
            Obx(() {
              final label = ctrl.appliedPromo.value?.label ?? 'Code appliqué !';
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Code appliqué — $label !',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    error,
                    style: TextStyle(fontSize: 12, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

// ── Résumé des prix ────────────────────────────────────────────────────────────

class _PriceSummary extends StatelessWidget {
  final CheckoutController ctrl;
  const _PriceSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Priorité aux données serveur si disponibles
      final prepared = ctrl.prepareResult.value;
      final subtotal = prepared?.subtotal.toDouble() ?? ctrl.subtotal;
      final deliveryFee = prepared?.deliveryFee.toDouble() ?? ctrl.deliveryFee;
      final discount = prepared?.discount.toDouble() ?? ctrl.discount;
      final total = prepared?.total.toDouble() ?? ctrl.total;
      final promoMsg = prepared?.promoMessage;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            _row('Sous-total', _fmt(subtotal)),
            const SizedBox(height: 10),
            _row('Livraison', deliveryFee == 0 ? 'Gratuit' : _fmt(deliveryFee)),
            if (discount > 0) ...[
              const SizedBox(height: 10),
              _row(
                promoMsg ?? 'Réduction',
                '− ${_fmt(discount)}',
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
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _fmt(total),
                  style: const TextStyle(
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
    }); // fin Obx
  }

  Widget _row(String label, String value, {Color? color}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textGray),
      ),
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
}

// ── Barre du bas ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final CheckoutController ctrl;
  const _BottomBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = ctrl.step.value == CheckoutStep.preparing;
      final total = ctrl.prepareResult.value?.total.toDouble() ?? ctrl.total;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: GestureDetector(
          onTap: loading ? null : ctrl.prepareOrder,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: loading
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: loading
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
              child: loading
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
                          '· ${_fmt(total)}',
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
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VUE PREUVE DE PAIEMENT MOMO
// ─────────────────────────────────────────────────────────────────────────────

class _MomoProofSheet extends StatelessWidget {
  final CheckoutController ctrl;
  const _MomoProofSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final momo = ctrl.prepareResult.value!.momo;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Étape header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFCC00).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCC00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.device_phone_portrait,
                    color: Color(0xFFE6A800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paiement MTN MoMo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Expire dans ${ctrl.prepareResult.value!.expiresIn}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Bannière confirmation ouverture automatique ───────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Le paiement MoMo a été ouvert automatiquement sur votre téléphone.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Re-composer si besoin ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paiement non reçu ?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        momo.ussdCode,
                        style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: AppColors.textGray,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(momo.ussdLink);
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFCC00).withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'Recomposer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Preuve de paiement'),
          const SizedBox(height: 6),
          const Text(
            'Après avoir effectué le paiement, joignez une capture d\'écran ou une photo de la confirmation MoMo.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Sélecteur image ─────────────────────────────────────────────────
          Obx(() {
            final path = ctrl.proofImagePath.value;
            return path != null
                ? _ProofPreview(path: path, ctrl: ctrl)
                : _ProofPicker(ctrl: ctrl);
          }),

          const SizedBox(height: 28),

          // ── Résumé montant ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Montant total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
                  ),
                ),
                Text(
                  _fmt(momo.amount.toDouble()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Bouton confirmer ────────────────────────────────────────────────
          Obx(() {
            final hasImage = ctrl.proofImagePath.value != null;
            final loading = ctrl.step.value == CheckoutStep.confirming;

            return GestureDetector(
              onTap: (hasImage && !loading) ? ctrl.confirmOrder : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  color: hasImage
                      ? (loading
                            ? AppColors.primary.withOpacity(0.6)
                            : AppColors.primary)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: hasImage && !loading
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          hasImage
                              ? 'Soumettre la commande'
                              : 'Ajoutez une preuve de paiement',
                          style: TextStyle(
                            color: hasImage ? Colors.white : AppColors.textGray,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Annuler ─────────────────────────────────────────────────────────
          GestureDetector(
            onTap: ctrl.resetToIdle,
            child: const Center(
              child: Text(
                'Annuler et modifier la commande',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofPicker extends StatelessWidget {
  final CheckoutController ctrl;
  const _ProofPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: ctrl.pickProofImage,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.photo,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Galerie',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: ctrl.takeProofPhoto,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.camera,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Appareil photo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProofPreview extends StatelessWidget {
  final String path;
  final CheckoutController ctrl;
  const _ProofPreview({required this.path, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            path,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Image sélectionnée',
                    style: TextStyle(fontSize: 13, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => ctrl.proofImagePath.value = null,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VUE SUCCÈS
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final CheckoutController ctrl;
  const _SuccessView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final order = ctrl.confirmResult.value!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commande soumise !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.reference,
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Votre commande est en attente de validation. Vous serez notifié dès confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: ctrl.goHome,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Retour à l'accueil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
