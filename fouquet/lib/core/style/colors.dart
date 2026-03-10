import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primaires (logo Le Fouquet) ──────────────────────────
  static const Color primary = Color(0xFF8DC63F); // Vert logo
  static const Color secondary = Color(0xFFE01A6A); // Rose/Magenta logo

  // ── Accent chaud (inspiré maquette café → adapté Fouquet) ─
  static const Color accent = Color(0xFFF5A623); // Orange chaud boutons
  static const Color accentDark = Color(0xFFE8912A); // Orange foncé hover

  // ── Fonds ───────────────────────────────────────────────
  static const Color bgSplash = Color(0xFF2C1810); // Fond splash (brun foncé)
  static const Color bgLight = Color(0xFFFFF8F0); // Fond écrans (crème chaud)
  static const Color bgCard = Color(0xFFFFFFFF); // Fond cartes
  static const Color bgPromo = Color(0xFFFDEDD5); // Fond bannière promo

  // ── Textes ──────────────────────────────────────────────
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF555555);
  static const Color textGray = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Catégories ──────────────────────────────────────────
  static const Color tagSelected = Color(0xFFF5A623);
  static const Color tagUnselected = Color(0xFFF0EDE8);

  // ── Badges ──────────────────────────────────────────────
  static const Color badgeTopSale = Color(0xFFF5A623);
  static const Color badgeOff = Color(0xFFE01A6A);

  // ── Utilitaires ─────────────────────────────────────────
  static const Color star = Color(0xFFF5A623);
  static const Color heart = Color(0xFFE01A6A);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);

  // ── Gradients ───────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFDEDD5), Color(0xFFFAE0C0)],
  );
}
