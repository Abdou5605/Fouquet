import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/style/colors.dart';

class BookSpaceScreen extends StatefulWidget {
  const BookSpaceScreen({super.key});

  @override
  State<BookSpaceScreen> createState() => _BookSpaceScreenState();
}

class _BookSpaceScreenState extends State<BookSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestsCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedEventType;
  bool _loading = false;

  final List<String> _eventTypes = [
    'Anniversaire 🎂',
    'Réunion d\'affaires 💼',
    'Fiançailles 💍',
    'Baby shower 🍼',
    'Repas en famille 👨‍👩‍👧‍👦',
    'Autre 🎉',
  ];

  @override
  void dispose() {
    _guestsCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Veuillez choisir une date');
      return;
    }
    if (_selectedTime == null) {
      _showError('Veuillez choisir une heure');
      return;
    }
    if (_selectedEventType == null) {
      _showError('Veuillez choisir un type d\'événement');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    _showSuccessDialog();
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

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Demande envoyée 🎉',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Votre demande de réservation a bien été envoyée. Notre équipe vous contactera pour confirmation.',
          style: TextStyle(color: AppColors.textGray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              'Super !',
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
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Réserver un espace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bannière ─────────────────────────────
              _buildBanner(),
              const SizedBox(height: 28),

              // ── Date & Heure ─────────────────────────
              _buildLabel('Date'),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 20),

              _buildLabel('Heure'),
              const SizedBox(height: 8),
              _buildTimePicker(),
              const SizedBox(height: 20),

              // ── Nombre de personnes ──────────────────
              _buildLabel('Nombre de personnes'),
              const SizedBox(height: 8),
              _buildGuestsField(),
              const SizedBox(height: 20),

              // ── Type d'événement ─────────────────────
              _buildLabel('Type d\'événement'),
              const SizedBox(height: 12),
              _buildEventTypeGrid(),
              const SizedBox(height: 20),

              // ── Message ──────────────────────────────
              _buildLabel('Message / Demande spéciale'),
              const SizedBox(height: 8),
              _buildMessageField(),
              const SizedBox(height: 36),

              // ── Bouton envoi ─────────────────────────
              _buildSubmitBtn(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bannière décorative ────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.celebration_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privatisez notre espace',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Anniversaires, réunions, fêtes… on s\'occupe de tout !',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Label ──────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── Sélecteur de date ──────────────────────────────────────
  Widget _buildDatePicker() {
    final label = _selectedDate == null
        ? 'Choisir une date'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
    return _buildPickerTile(
      icon: Icons.calendar_today_outlined,
      label: label,
      hasValue: _selectedDate != null,
      onTap: _pickDate,
    );
  }

  // ── Sélecteur d'heure ──────────────────────────────────────
  Widget _buildTimePicker() {
    final label = _selectedTime == null
        ? 'Choisir une heure'
        : _selectedTime!.format(context);
    return _buildPickerTile(
      icon: Icons.access_time_rounded,
      label: label,
      hasValue: _selectedTime != null,
      onTap: _pickTime,
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue ? AppColors.textDark : AppColors.textGray,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Champ nombre de personnes ──────────────────────────────
  Widget _buildGuestsField() {
    return TextFormField(
      controller: _guestsCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Nombre de personnes requis';
        if (int.parse(v) < 1) return 'Minimum 1 personne';
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Ex : 20',
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        prefixIcon: Icon(
          Icons.group_outlined,
          color: AppColors.primary,
          size: 20,
        ),
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
      ),
    );
  }

  // ── Grille types d'événement ───────────────────────────────
  Widget _buildEventTypeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _eventTypes.map((type) {
        final selected = _selectedEventType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedEventType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textMedium,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Champ message ──────────────────────────────────────────
  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageCtrl,
      maxLines: 4,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Décrivez vos besoins, thème souhaité, allergies…',
        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.all(16),
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
    );
  }

  // ── Bouton envoi ───────────────────────────────────────────
  Widget _buildSubmitBtn() {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
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
                    color: AppColors.primary.withOpacity(0.30),
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
              : const Text(
                  'Envoyer la demande',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
