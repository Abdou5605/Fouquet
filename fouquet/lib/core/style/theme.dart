import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgLight,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.bgCard,
      background: AppColors.bgLight,
    ),

    // ── Typographie ────────────────────────────────────────
    // Great Vibes pour les titres (displayLarge → titleMedium)
    // Nunito pour le reste (bodyLarge → labelSmall)
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.greatVibes(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.greatVibes(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      displaySmall: GoogleFonts.greatVibes(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      headlineLarge: GoogleFonts.greatVibes(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.greatVibes(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.greatVibes(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.greatVibes(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.greatVibes(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
    ),

    // ── AppBar ─────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textDark),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.greatVibes(
        // ← Great Vibes pour le titre de l'AppBar
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
    ),

    // ── BottomNavigationBar ────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textGray,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
    ),

    // ── ElevatedButton ─────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 54),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),

    // ── OutlinedButton ─────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        textStyle: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Card ───────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 6,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    // ── InputDecoration ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.textGray),
    ),

    // ── Divider ────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
  );
}
