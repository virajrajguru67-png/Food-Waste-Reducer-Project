import 'package:flutter/material.dart';
import '../theme/app_animations.dart';

class MicroInteractions {
  // Button press animation
  static Widget buttonPressAnimation(Widget child, VoidCallback? onTap) {
    return GestureDetector(
      onTapDown: (_) {},
      onTapUp: (_) => onTap?.call(),
      onTapCancel: () {},
      child: child,
    );
  }

  // Card tap animation
  static Widget cardTapAnimation(Widget child, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        child: child,
      ),
    );
  }

  // Ripple effect
  static Widget rippleEffect(Widget child, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }
}

