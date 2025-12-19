import 'package:flutter/material.dart';

/// Animation constants and durations
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInOutCubic;

  // Animation configurations
  static const Duration pageTransitionDuration = normal;
  static const Duration cardAnimationDuration = normal;
  static const Duration buttonPressDuration = fast;
  static const Duration shimmerDuration = Duration(milliseconds: 1200);

  // Stagger delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
}

