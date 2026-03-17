import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Map<String, dynamic> _args =
      Get.arguments ??
      {
        'total': 11500,
        'items': 3,
        'deliveryMode': 'Livraison',
        'paymentMethod': 0,
      };
  late int _selectedMethod;

  final _phoneCtrl = TextEditingController();
  final _cardNumCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureCvv = true;

  @override
  void initState() {
    super.initState();
    _selectedMethod = _args['paymentMethod'] ?? 0;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cardNumCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  int get _total => _args['total'] ?? 0;

  final List<Map<String, dynamic>> _methods = const [
    {
      'label': 'MTN Mobile Money',
      'sub': 'MTN MoMo',
      'color': Color(0xFFFFCC00),
      'icon': CupertinoIcons.device_phone_portrait,
    },
    {
      'label': 'Moov Money',
      'sub': 'Flooz',
      'color': Color(0xFF0055A4),
      'icon': CupertinoIcons.device_phone_portrait,
    },
    {
      'label': 'Carte bancaire',
      'sub': 'Visa / Mastercard',
      'color': Colors.purple,
      'icon': CupertinoIcons.creditcard,
    },
    {
      'label': 'Espèces',
      'sub': 'À la livraison',
      'color': Colors.green,
      'icon': CupertinoIcons.money_dollar_circle,
    },
  ];

  void _pay() {
    if (_selectedMethod == 0 || _selectedMethod == 1) {
      if (_phoneCtrl.text.trim().length < 8) {
        _showError('Veuillez entrer un numéro valide');
        return;
      }
    } else if (_selectedMethod == 2) {
      if (_cardNumCtrl.text.replaceAll(' ', '').length < 16) {
        _showError('Numéro de carte invalide');
        return;
      }
      if (_cardNameCtrl.text.trim().isEmpty) {
        _showError('Nom du titulaire requis');
        return;
      }
      if (_expiryCtrl.text.trim().length < 5) {
        _showError('Date d\'expiration invalide');
        return;
      }
      if (_cvvCtrl.text.trim().length < 3) {
        _showError('CVV invalide');
        return;
      }
    }
    _showConfirmDialog();
  }

  void _showError(String msg) {
    Get.snackbar(
      'Champ manquant',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.secondary.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showConfirmDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer le paiement',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant total',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                  Text(
                    '$_total FCFA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Paiement via ${_methods[_selectedMethod]['label']}. Cette action est irréversible.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // ferme le dialog de confirmation
              setState(() => _loading = true);
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) return;
              setState(() => _loading = false);
              _showSuccessDialog(); // affiche le dialog de succès
            },
            child: Text(
              'Payer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône succès
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
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
              'Paiement réussi !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre paiement de $_total FCFA a bien été effectué. Votre commande est en cours de traitement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Récapitulatif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _successRow(
                    'Méthode',
                    _methods[_selectedMethod]['label'] as String,
                  ),
                  const SizedBox(height: 6),
                  _successRow('Montant', '$_total FCFA'),
                  const SizedBox(height: 6),
                  _successRow('Statut', 'Confirmé ✓'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () {
                Get.back(); // ferme le dialog
                Get.offAllNamed(AppRoutes.home); // retour à l'accueil
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.textGray)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
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
            _buildAmountCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Mode de paiement'),
            const SizedBox(height: 12),
            _buildMethodSelector(),
            const SizedBox(height: 24),
            if (_selectedMethod == 0 || _selectedMethod == 1) ...[
              _buildSectionTitle(
                'Numéro ${_selectedMethod == 0 ? 'MTN' : 'Moov'}',
              ),
              const SizedBox(height: 12),
              _buildMobileMoneyForm(),
            ] else if (_selectedMethod == 2) ...[
              _buildSectionTitle('Informations de la carte'),
              const SizedBox(height: 12),
              _buildCardForm(),
            ] else ...[
              _buildCashInfo(),
            ],
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
      'Paiement',
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

  Widget _buildAmountCard() => Container(
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
          'Montant à payer',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 10),
        Text(
          '$_total FCFA',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _amountDetail(
              CupertinoIcons.bag,
              '${_args['items'] ?? 0} articles',
            ), // ✅
            const SizedBox(width: 20),
            _amountDetail(
              CupertinoIcons.car_detailed,
              _args['deliveryMode'] ?? 'Livraison',
            ), // ✅
          ],
        ),
      ],
    ),
  );

  Widget _amountDetail(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
      ),
    ],
  );

  Widget _buildMethodSelector() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      children: List.generate(_methods.length, (i) {
        final m = _methods[i];
        final selected = _selectedMethod == i;
        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = i),
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
            if (i < _methods.length - 1)
              Divider(height: 1, indent: 68, color: AppColors.divider),
          ],
        );
      }),
    ),
  );

  Widget _buildMobileMoneyForm() => Column(
    children: [
      _buildInfoBanner(
        icon: CupertinoIcons.info_circle,
        text:
            'Vous recevrez une invite de paiement sur ce numéro. Assurez-vous d\'avoir le solde suffisant.',
      ), // ✅
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        decoration: _inputDeco(
          hint: '00 00 00 00',
          icon: CupertinoIcons.phone,
        ), // ✅
      ),
    ],
  );

  Widget _buildCardForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: _cardNumCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CardNumberFormatter(),
        ],
        maxLength: 19,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        decoration: _inputDeco(
          hint: '0000 0000 0000 0000',
          icon: CupertinoIcons.creditcard,
        ).copyWith(counterText: ''), // ✅
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _cardNameCtrl,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        decoration: _inputDeco(
          hint: 'NOM PRÉNOM',
          icon: CupertinoIcons.person,
        ), // ✅
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _expiryCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ExpiryFormatter(),
              ],
              maxLength: 5,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              decoration: _inputDeco(
                hint: 'MM/AA',
                icon: CupertinoIcons.calendar,
              ).copyWith(counterText: ''), // ✅
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _cvvCtrl,
              keyboardType: TextInputType.number,
              obscureText: _obscureCvv,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
              decoration: _inputDeco(hint: '•••', icon: CupertinoIcons.lock)
                  .copyWith(
                    // ✅
                    counterText: '',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _obscureCvv = !_obscureCvv),
                        child: Icon(
                          _obscureCvv
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          color: AppColors.textGray,
                          size: 18,
                        ), // ✅
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _buildInfoBanner(
        icon: CupertinoIcons.shield,
        text: 'Vos informations bancaires sont chiffrées et sécurisées.',
      ), // ✅
    ],
  );

  Widget _buildCashInfo() => _buildInfoBanner(
    icon: CupertinoIcons.money_dollar_circle, // ✅
    text:
        'Préparez le montant exact de $_total FCFA. Le livreur ne dispose pas toujours de monnaie.',
    color: Colors.green,
  );

  Widget _buildInfoBanner({
    required IconData icon,
    required String text,
    Color? color,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputDeco({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      );

  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    decoration: BoxDecoration(
      color: AppColors.bgLight,
      border: Border(top: BorderSide(color: AppColors.divider)),
    ),
    child: GestureDetector(
      onTap: _loading ? null : _pay,
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
                    const Icon(
                      CupertinoIcons.lock,
                      color: Colors.white,
                      size: 18,
                    ), // ✅
                    const SizedBox(width: 8),
                    Text(
                      'Payer $_total FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
