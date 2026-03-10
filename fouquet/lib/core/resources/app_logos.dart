class AppLogos {
  AppLogos._();

  static const String _base = 'assets/images/logo';

  // ── Variantes du logo Le Fouquet ──────────────────────
  static const String full = '$_base/logo_full.png'; // Logo complet couleur
  static const String fullWhite =
      '$_base/logo_full_white.png'; // Logo blanc (fonds sombres)
  static const String iconOnly =
      '$_base/logo_icon_only.png'; // Toque + cloche seule
  static const String textOnly =
      '$_base/logo_text_only.png'; // "le Fouquet" sans toque

  // ── Icône app (stores) ────────────────────────────────
  static const String _app = 'assets/icons/app';
  static const String appIcon1024 = '$_app/app_icon_1024.png';
  static const String appIconAndroid = '$_app/app_icon_android.png';
  static const String appIconIos = '$_app/app_icon_ios.png';
  static const String appIconAdaptiveFg = '$_app/app_icon_adaptive_fg.png';
}
