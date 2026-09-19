import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Primary & Accents (Warm Clinical Health Palette)
  static const Color primarySlate = Color(0xFF12161A); // Deep warm charcoal slate
  static const Color primaryTeal = Color(0xFFFF6542);  // Warm Vitality Terracotta / Coral
  static const Color accentEmerald = Color(0xFF10B981);// Vitality sage green
  static const Color accentCyan = Color(0xFFF59E0B);   // Warm golden amber

  // Warm Health Palette Tokens
  static const Color darkCanvas = Color(0xFF0F1317);     // Warm deep charcoal canvas
  static const Color darkSurface = Color(0xFF161B21);    // Warm espresso slate panel
  static const Color darkCard = Color(0xFF1C232B);       // Warm elevated health card
  static const Color darkCardHover = Color(0xFF242D38);  // Elevated warm card
  static const Color darkBorder = Color(0xFF2B3642);     // Warm slate border
  static const Color cyberCyan = Color(0xFFFF6542);      // Warm Vitality Terracotta (Cardio & Vitality)
  static const Color cyberBlue = Color(0xFFFB923C);      // Warm Peach / Orange (Stamina & Energy)
  static const Color bioEmerald = Color(0xFF10B981);     // Longevity & Recovery Sage Green
  static const Color neonAmber = Color(0xFFF59E0B);      // Circadian Sunrise Amber / Caution
  static const Color neonRed = Color(0xFFF43F5E);        // Critical / Emergency Rose Crimson
  static const Color neonPurple = Color(0xFFA855F7);     // Circadian Sleep & Neuro Amethyst

  // Cyber & Obsidian Aliases (Preserved for full backward compatibility)
  static const Color obsidianBase = darkCanvas;
  static const Color obsidianCard = darkCard;
  static const Color obsidianBorder = darkBorder;
  static const Color obsidianGlass = Color(0xDD1C232B);
  static const Color neonCyan = cyberCyan;
  static const Color neonEmerald = bioEmerald;
  static const Color neonCrimson = neonRed;

  // Surface & Neutral Backgrounds
  static const Color backgroundLight = darkCanvas;
  static const Color surfaceWhite = darkCard;
  static const Color surfaceSubtle = darkSurface;
  static const Color borderLight = darkBorder;

  // Text Colors
  static const Color textDark = textPrimary;
  static const Color textMedium = textSecondary;
  static const Color textMuted = Color(0xFF717F91);

  // Warm Health Text Tokens
  static const Color textPrimary = Color(0xFFF8FAFC);   // Crisp warm off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Soft warm slate
  static const Color textTertiary = Color(0xFF64748B);  // Subtle hint slate

  // Functional & Semantic Health Colors
  static const Color healthyGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFF43F5E);
  static const Color infoBlue = Color(0xFFFB923C);

  // Warm Health Card & HUD Container Helpers
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? backgroundColor,
    double borderRadius = 20,
    bool glowing = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? darkCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? darkBorder,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: glowing
              ? (borderColor ?? cyberCyan).withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.3),
          blurRadius: glowing ? 16 : 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration hudGlassDecoration({
    Color? accentColor,
    double borderRadius = 24,
  }) {
    final accent = accentColor ?? cyberCyan;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.12),
          darkCard.withValues(alpha: 0.96),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accent.withValues(alpha: 0.3),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Warm Health Dark Theme
  static ThemeData get futuristicDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: cyberCyan,
      scaffoldBackgroundColor: darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: cyberCyan,
        secondary: bioEmerald,
        tertiary: neonAmber,
        surface: darkSurface,
        error: neonRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: textTertiary,
          fontSize: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonRed, width: 1),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyberCyan,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyberCyan,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          side: const BorderSide(color: cyberCyan, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        disabledColor: darkBorder,
        selectedColor: cyberCyan.withValues(alpha: 0.2),
        secondarySelectedColor: cyberCyan,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: cyberCyan,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: cyberCyan,
        unselectedItemColor: textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Aliased getter for backward-compatibility
  static ThemeData get lightTheme => futuristicDarkTheme;
  static ThemeData get warmHealthTheme => futuristicDarkTheme;
}