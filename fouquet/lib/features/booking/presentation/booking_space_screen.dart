// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fouquet/core/style/colors.dart';

// class BookSpaceScreen extends StatefulWidget {
//   const BookSpaceScreen({super.key});

//   @override
//   State<BookSpaceScreen> createState() => _BookSpaceScreenState();
// }

// class _BookSpaceScreenState extends State<BookSpaceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _guestsCtrl = TextEditingController();
//   final _messageCtrl = TextEditingController();

//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String? _selectedEventType;
//   bool _loading = false;

//   final List<String> _eventTypes = [
//     'Anniversaire 🎂',
//     'Réunion d\'affaires 💼',
//     'Fiançailles 💍',
//     'Baby shower 🍼',
//     'Repas en famille 👨‍👩‍👧‍👦',
//     'Autre 🎉',
//   ];

//   // ── Helper Nunito ──────────────────────────────────────────────────────────
//   static TextStyle _nunito({
//     double size = 14,
//     FontWeight weight = FontWeight.w400,
//     Color? color,
//     double height = 1.0,
//     double letterSpacing = 0.0,
//   }) => GoogleFonts.nunito(
//     fontSize: size,
//     fontWeight: weight,
//     color: color,
//     height: height,
//     letterSpacing: letterSpacing,
//   );

//   @override
//   void dispose() {
//     _guestsCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: now.add(const Duration(days: 1)),
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(
//           ctx,
//         ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
//         child: child!,
//       ),
//     );
//     if (picked != null) setState(() => _selectedDate = picked);
//   }

//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 12, minute: 0),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(
//           ctx,
//         ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
//         child: child!,
//       ),
//     );
//     if (picked != null) setState(() => _selectedTime = picked);
//   }

//   void _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedDate == null) {
//       _showError('Veuillez choisir une date');
//       return;
//     }
//     if (_selectedTime == null) {
//       _showError('Veuillez choisir une heure');
//       return;
//     }
//     if (_selectedEventType == null) {
//       _showError('Veuillez choisir un type d\'événement');
//       return;
//     }
//     setState(() => _loading = true);
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() => _loading = false);
//     _showSuccessDialog();
//   }

//   void _showError(String msg) {
//     Get.snackbar(
//       'Champ manquant',
//       msg,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: AppColors.secondary.withOpacity(0.9),
//       colorText: Colors.white,
//       borderRadius: 14,
//       margin: const EdgeInsets.all(16),
//     );
//   }

//   void _showSuccessDialog() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(
//           'Demande envoyée 🎉',
//           style: _nunito(weight: FontWeight.w800, color: AppColors.textDark),
//         ),
//         content: Text(
//           'Votre demande de réservation a bien été envoyée. Notre équipe vous contactera pour confirmation.',
//           style: _nunito(size: 14, color: AppColors.textGray),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back();
//               Get.back();
//             },
//             child: Text(
//               'Super !',
//               style: _nunito(weight: FontWeight.w800, color: AppColors.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgLight,
//       appBar: AppBar(
//         backgroundColor: AppColors.bgLight,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Get.back(),
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.bgCard,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.divider),
//             ),
//             child: const Icon(
//               CupertinoIcons.arrow_left,
//               color: AppColors.textDark,
//               size: 18,
//             ),
//           ),
//         ),
//         title: Text(
//           'Réserver un espace',
//           style: _nunito(
//             size: 18,
//             weight: FontWeight.w800,
//             color: AppColors.textDark,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildBanner(),
//               const SizedBox(height: 28),
//               _buildLabel('Date'),
//               const SizedBox(height: 8),
//               _buildDatePicker(),
//               const SizedBox(height: 20),
//               _buildLabel('Heure'),
//               const SizedBox(height: 8),
//               _buildTimePicker(),
//               const SizedBox(height: 20),
//               _buildLabel('Nombre de personnes'),
//               const SizedBox(height: 8),
//               _buildGuestsField(),
//               const SizedBox(height: 20),
//               _buildLabel('Type d\'événement'),
//               const SizedBox(height: 12),
//               _buildEventTypeGrid(),
//               const SizedBox(height: 20),
//               _buildLabel('Message / Demande spéciale'),
//               const SizedBox(height: 8),
//               _buildMessageField(),
//               const SizedBox(height: 36),
//               _buildSubmitBtn(),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bannière ──────────────────────────────────────────────────────────────
//   Widget _buildBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(
//               CupertinoIcons.calendar_badge_plus,
//               color: AppColors.primary,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Privatisez notre espace',
//                   style: _nunito(
//                     size: 15,
//                     weight: FontWeight.w800,
//                     color: AppColors.textDark,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Anniversaires, réunions, fêtes… on s\'occupe de tout !',
//                   style: _nunito(
//                     size: 12,
//                     color: AppColors.textGray,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Label champ ───────────────────────────────────────────────────────────
//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: _nunito(
//         size: 13,
//         weight: FontWeight.w700,
//         color: AppColors.textDark,
//         letterSpacing: 0.2,
//       ),
//     );
//   }

//   // ── Sélecteur de date ─────────────────────────────────────────────────────
//   Widget _buildDatePicker() {
//     final label = _selectedDate == null
//         ? 'Choisir une date'
//         : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
//     return _buildPickerTile(
//       icon: CupertinoIcons.calendar,
//       label: label,
//       hasValue: _selectedDate != null,
//       onTap: _pickDate,
//     );
//   }

//   // ── Sélecteur d'heure ─────────────────────────────────────────────────────
//   Widget _buildTimePicker() {
//     final label = _selectedTime == null
//         ? 'Choisir une heure'
//         : _selectedTime!.format(context);
//     return _buildPickerTile(
//       icon: CupertinoIcons.clock,
//       label: label,
//       hasValue: _selectedTime != null,
//       onTap: _pickTime,
//     );
//   }

//   Widget _buildPickerTile({
//     required IconData icon,
//     required String label,
//     required bool hasValue,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 54,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: AppColors.bgCard,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.divider, width: 1.5),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: AppColors.primary, size: 20),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: _nunito(
//                   size: 14,
//                   color: hasValue ? AppColors.textDark : AppColors.textGray,
//                 ),
//               ),
//             ),
//             Icon(
//               CupertinoIcons.chevron_right,
//               color: AppColors.textGray,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Champ nombre de personnes ─────────────────────────────────────────────
//   Widget _buildGuestsField() {
//     return TextFormField(
//       controller: _guestsCtrl,
//       keyboardType: TextInputType.number,
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       style: _nunito(size: 14, color: AppColors.textDark),
//       validator: (v) {
//         if (v == null || v.isEmpty) return 'Nombre de personnes requis';
//         if (int.parse(v) < 1) return 'Minimum 1 personne';
//         return null;
//       },
//       decoration: InputDecoration(
//         hintText: 'Ex : 20',
//         hintStyle: _nunito(size: 14, color: AppColors.textGray),
//         prefixIcon: Icon(
//           CupertinoIcons.group,
//           color: AppColors.primary,
//           size: 20,
//         ),
//         filled: true,
//         fillColor: AppColors.bgCard,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 17,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.divider, width: 1.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.secondary, width: 2),
//         ),
//       ),
//     );
//   }

//   // ── Grille type d'événement ───────────────────────────────────────────────
//   Widget _buildEventTypeGrid() {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: _eventTypes.map((type) {
//         final selected = _selectedEventType == type;
//         return GestureDetector(
//           onTap: () => setState(() => _selectedEventType = type),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: selected ? AppColors.primary : AppColors.bgCard,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: selected ? AppColors.primary : AppColors.divider,
//                 width: 1.5,
//               ),
//             ),
//             child: Text(
//               type,
//               style: _nunito(
//                 size: 13,
//                 weight: FontWeight.w600,
//                 color: selected ? Colors.white : AppColors.textMedium,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ── Champ message ─────────────────────────────────────────────────────────
//   Widget _buildMessageField() {
//     return TextFormField(
//       controller: _messageCtrl,
//       maxLines: 4,
//       style: _nunito(size: 14, color: AppColors.textDark),
//       decoration: InputDecoration(
//         hintText: 'Décrivez vos besoins, thème souhaité, allergies…',
//         hintStyle: _nunito(size: 14, color: AppColors.textGray),
//         filled: true,
//         fillColor: AppColors.bgCard,
//         contentPadding: const EdgeInsets.all(16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.divider, width: 1.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//       ),
//     );
//   }

//   // ── Bouton envoyer ────────────────────────────────────────────────────────
//   Widget _buildSubmitBtn() {
//     return GestureDetector(
//       onTap: _loading ? null : _submit,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: double.infinity,
//         height: 56,
//         decoration: BoxDecoration(
//           color: _loading
//               ? AppColors.primary.withOpacity(0.6)
//               : AppColors.primary,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: _loading
//               ? []
//               : [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.30),
//                     blurRadius: 18,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//         ),
//         child: Center(
//           child: _loading
//               ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2.5,
//                   ),
//                 )
//               : Text(
//                   'Envoyer la demande',
//                   style: _nunito(
//                     size: 15,
//                     weight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fouquet/core/style/colors.dart';

class BookSpaceScreen extends StatelessWidget {
  const BookSpaceScreen({super.key});

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

  // ── Numéro du restaurant ── À MODIFIER ────────────────────────────────────
  static const String _phone = '+229 XX XX XX XX';
  static const String _phoneDialable = '+229XXXXXXXX';

  Future<void> _callRestaurant() async {
    final uri = Uri.parse('tel:$_phoneDialable');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final uri = Uri.parse(
      'https://wa.me/${_phoneDialable.replaceAll('+', '')}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Types de réservation ──────────────────────────────────────────────────
  static const List<Map<String, String>> _reservationTypes = [
    {
      'emoji': '🍽️',
      'title': 'Réservation de table',
      'desc':
          'Réservez votre table pour un dîner ou déjeuner en toute tranquillité.',
    },
    {
      'emoji': '🎂',
      'title': 'Anniversaire',
      'desc': 'Fêtez vos anniversaires dans un cadre chaleureux et festif.',
    },
    {
      'emoji': '🙏',
      'title': 'Baptême',
      'desc': 'Célébrez l\'arrivée de votre petit bonheur avec vos proches.',
    },
    {
      'emoji': '💍',
      'title': 'Fiançailles',
      'desc': 'Un moment unique et inoubliable pour officialiser votre amour.',
    },
    {
      'emoji': '👨‍👩‍👧‍👦',
      'title': 'Repas en famille',
      'desc': 'Rassemblez toute la famille autour d\'une belle table.',
    },
    {
      'emoji': '💼',
      'title': 'Réunion d\'affaires',
      'desc':
          'Un espace privatisé et professionnel pour vos rencontres business.',
    },
    {
      'emoji': '🎉',
      'title': 'Privatisation de l\'espace',
      'desc': 'Réservez tout l\'espace pour votre événement sur mesure.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
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
          'Réservations',
          style: _nunito(
            size: 18,
            weight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────────
            _buildHero(),
            const SizedBox(height: 28),

            // ── Intro texte ───────────────────────────────────────────────
            _buildIntroText(),
            const SizedBox(height: 28),

            // ── Types de réservation ─────────────────────────────────────
            Text(
              'Ce que nous proposons',
              style: _nunito(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            ..._reservationTypes.map((r) => _buildReservationCard(r)),

            const SizedBox(height: 28),

            // ── Contact ───────────────────────────────────────────────────
            _buildContactSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Réservez chez nous',
            style: _nunito(
              size: 22,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tables, événements privés, fêtes… nous sommes là pour rendre chaque moment spécial.',
            style: _nunito(
              size: 13,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Intro ─────────────────────────────────────────────────────────────────
  Widget _buildIntroText() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Comment réserver ?',
                style: _nunito(
                  size: 14,
                  weight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pour effectuer une réservation — que ce soit pour une table ou un événement privé — il vous suffit de nous contacter directement par téléphone ou WhatsApp. Notre équipe se fera un plaisir de vous accompagner et de préparer votre moment sur mesure.',
            style: _nunito(size: 13, color: AppColors.textGray, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Carte type réservation ────────────────────────────────────────────────
  Widget _buildReservationCard(Map<String, String> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(r['emoji']!, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['title']!,
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r['desc']!,
                  style: _nunito(
                    size: 12,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section contact ───────────────────────────────────────────────────────
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nous contacter',
          style: _nunito(
            size: 16,
            weight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),

        // Numéro affiché
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.phone_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appelez-nous',
                      style: _nunito(
                        size: 12,
                        color: AppColors.textGray,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _phone,
                      style: _nunito(
                        size: 18,
                        weight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Boutons Appeler + WhatsApp
        Row(
          children: [
            Expanded(child: _buildCallBtn()),
            const SizedBox(width: 12),
            Expanded(child: _buildWhatsAppBtn()),
          ],
        ),
      ],
    );
  }

  Widget _buildCallBtn() {
    return GestureDetector(
      onTap: _callRestaurant,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.phone_fill,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Appeler',
              style: _nunito(
                size: 14,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppBtn() {
    return GestureDetector(
      onTap: _whatsapp,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.chat_bubble_fill,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'WhatsApp',
              style: _nunito(
                size: 14,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
