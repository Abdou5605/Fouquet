import 'package:flutter/material.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display / Hero (Splash) ──────────────────────────────
  static TextStyle splashTitle = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.3,
  );

  static TextStyle splashSubtitle = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    height: 1.6,
  );

  // ── Greeting (Home) ─────────────────────────────────────
  static TextStyle greetingName = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static TextStyle greetingText = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray,
  );

  // ── Section titles ──────────────────────────────────────
  static TextStyle sectionTitle = GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static TextStyle sectionLink = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
  );

  // ── Promo Banner ────────────────────────────────────────
  static TextStyle promoTag = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  static TextStyle promoDiscount = GoogleFonts.fredoka(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle promoSubtitle = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );

  // ── Category chips ──────────────────────────────────────
  static TextStyle categorySelected = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle categoryUnselected = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
  );

  // ── Product card ────────────────────────────────────────
  static TextStyle productName = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle productPrice = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static TextStyle productPriceOld = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray,
    decoration: TextDecoration.lineThrough,
  );

  // ── Detail Screen ───────────────────────────────────────
  static TextStyle detailTitle = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static TextStyle detailRating = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
  );

  static TextStyle detailSectionLabel = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle detailDescription = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.6,
  );

  static TextStyle detailPrice = GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // ── Options (Size, Sugar, Ice) ──────────────────────────
  static TextStyle optionSelected = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  static TextStyle optionUnselected = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );

  // ── Boutons ─────────────────────────────────────────────
  static TextStyle buttonPrimary = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
  );

  // ── Bottom nav ──────────────────────────────────────────
  static TextStyle navLabel = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
