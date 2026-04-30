import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouquet/features/profile/service/profile_api_service.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';
import 'package:fouquet/core/presentation/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Obx(() {
          // ── Loading initial ──────────────────────────
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 24),
                _buildMenuSection(
                  title: 'Mon Compte',
                  items: [
                    _MenuItem(
                      icon: CupertinoIcons.person,
                      label: 'Modifier le profil',
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.clock,
                      label: 'Historique commandes',
                      onTap: () => Get.toNamed(AppRoutes.orderHistory),
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.heart,
                      label: 'Mes favoris',
                      onTap: () => Get.toNamed(AppRoutes.favorites),
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.gift,
                      label: 'Parrainage & Réductions',
                      onTap: () => Get.toNamed(AppRoutes.referral),
                      badge: 'NEW',
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.calendar,
                      label: 'Réserver un espace',
                      onTap: () => Get.toNamed(AppRoutes.bookSpace),
                      badge: 'NEW',
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.lock,
                      label: 'Changer mot de passe',
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMenuSection(
                  title: 'Préférences',
                  items: [
                    _MenuItem(
                      icon: CupertinoIcons.bell,
                      label: 'Notifications',
                      onTap: () {},
                      trailing: _buildSwitch(),
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.info_circle,
                      label: 'À propos',
                      onTap: () {},
                      subtitle: 'Version 1.0.0',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMenuSection(
                  title: 'Assistance',
                  items: [
                    _MenuItem(
                      icon: CupertinoIcons.question_circle,
                      label: 'Centre d\'aide',
                      onTap: () => Get.toNamed(AppRoutes.helpCenter),
                    ),
                    _MenuItem(
                      icon: CupertinoIcons.chat_bubble,
                      label: 'Nous contacter',
                      onTap: () => Get.toNamed(AppRoutes.contact),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _buildMenuItem(
                      _MenuItem(
                        icon: CupertinoIcons.delete,
                        label: 'Supprimer votre compte',
                        onTap: _showDeleteDialog,
                        danger: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLogoutBtn(),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Header avec données réelles ──────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              const Expanded(
                child: Text(
                  'Profil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Avatar ──────────────────────────────────
          Obx(
            () => Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(child: _buildAvatar()),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _controller.showImagePicker(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.badgeOff,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        CupertinoIcons.camera,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Nom & Email réels ────────────────────────
          Obx(
            () => Text(
              _controller.fullName.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              _controller.email.value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar : local > url > placeholder ───────────────
  Widget _buildAvatar() {
    if (_controller.profileImage.value != null) {
      return Image.file(_controller.profileImage.value!, fit: BoxFit.cover);
    }
    if (_controller.avatarUrl.value != null) {
      return Image.network(
        _controller.avatarUrl.value!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarPlaceholder(),
      );
    }
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() => Container(
    color: AppColors.bgLight,
    child: const Icon(
      CupertinoIcons.person,
      size: 50,
      color: AppColors.textGray,
    ),
  );

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            _statItem('12', 'Commandes'),
            _divider(),
            _statItem('5', 'Favoris'),
            _divider(),
            _statItem('4.8', 'Note'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.badgeOff,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: AppColors.divider);

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              children: List.generate(
                items.length,
                (i) => Column(
                  children: [
                    _buildMenuItem(items[i]),
                    if (i < items.length - 1)
                      Divider(height: 1, indent: 56, color: AppColors.divider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    final iconColor = item.danger ? AppColors.badgeOff : AppColors.primary;
    return GestureDetector(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.danger
                          ? AppColors.secondary
                          : AppColors.textDark,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                ],
              ),
            ),
            if (item.badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeOff,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            item.trailing ??
                Icon(
                  CupertinoIcons.chevron_right,
                  color: item.danger
                      ? AppColors.secondary.withOpacity(0.5)
                      : AppColors.textGray,
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog suppression compte ────────────────────────
  void _showDeleteDialog() {
    final passwordCtrl = TextEditingController();
    final obscure = true.obs;
    final loading = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icône ────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.delete,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // ── Titre ─────────────────────────────────
              const Text(
                'Supprimer le compte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // ── Avertissement ─────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cette action est irréversible. Toutes vos données, commandes et favoris seront supprimés définitivement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Champ mot de passe ────────────────────
              Obx(
                () => TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscure.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Votre mot de passe',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => obscure.value = !obscure.value,
                      child: Icon(
                        obscure.value
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: AppColors.textGray,
                        size: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.bgLight,
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
                      borderSide: BorderSide(
                        color: AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Boutons ───────────────────────────────
              Row(
                children: [
                  // Annuler
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Supprimer
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: loading.value
                            ? null
                            : () async {
                                final pwd = passwordCtrl.text.trim();
                                if (pwd.isEmpty) {
                                  showErrorToast(
                                    'Erreur',
                                    description:
                                        'Veuillez entrer votre mot de passe.',
                                  );
                                  return;
                                }
                                loading.value = true;
                                final success =
                                    await ProfileApiService.deleteAccount(
                                      password: pwd,
                                    );
                                loading.value = false;

                                if (success) {
                                  Get.back(); // ferme le dialog
                                  showSuccessToast(
                                    'Compte supprimé',
                                    description: 'Votre compte a été supprimé.',
                                  );
                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );
                                  Get.offAllNamed(AppRoutes.login);
                                }
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 46,
                          decoration: BoxDecoration(
                            color: loading.value
                                ? AppColors.secondary.withOpacity(0.6)
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: loading.value
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(
                                        0.30,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Supprimer',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSwitch() => _SwitchWidget();

  // ─── Bouton déconnexion ───────────────────────────────
  Widget _buildLogoutBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => GestureDetector(
          onTap: _controller.isLoggingOut.value
              ? null
              : _controller.showLogoutDialog,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Center(
              child: _controller.isLoggingOut.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.square_arrow_left,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool danger;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.trailing,
    this.danger = false,
  });
}

class _SwitchWidget extends StatefulWidget {
  @override
  State<_SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<_SwitchWidget> {
  bool _value = true;
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      activeColor: AppColors.badgeOff,
    );
  }
}
