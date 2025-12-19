import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stylish professional typography system
class AppTextStyles {
  AppTextStyles._();

  // Headings - Refined and professional
  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0,
      );

  // Subheadings - Professional
  static TextStyle get subheading1 => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get subheading2 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  // Body Text - Clean and readable
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // Captions
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.15,
      );

  // Buttons - Stylish and professional
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.4,
      );

  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
      );

  // Overrides with colors
  static TextStyle heading1WithColor(Color color) => heading1.copyWith(color: color);
  static TextStyle heading2WithColor(Color color) => heading2.copyWith(color: color);
  static TextStyle heading3WithColor(Color color) => heading3.copyWith(color: color);
  static TextStyle subheading1WithColor(Color color) => subheading1.copyWith(color: color);
  static TextStyle subheading2WithColor(Color color) => subheading2.copyWith(color: color);
  static TextStyle bodyLargeWithColor(Color color) => bodyLarge.copyWith(color: color);
  static TextStyle bodyMediumWithColor(Color color) => bodyMedium.copyWith(color: color);
  static TextStyle bodySmallWithColor(Color color) => bodySmall.copyWith(color: color);
  static TextStyle captionWithColor(Color color) => caption.copyWith(color: color);
}
