import 'package:flutter/material.dart';
import '../theme/app_animations.dart';

class CustomPageTransitions {
  static Route<T> fadeTransition<T extends Object?>(
    Widget page,
  ) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: AppAnimations.pageTransitionDuration,
    );
  }

  static Route<T> slideTransition<T extends Object?>(
    Widget page, {
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.smoothCurve,
          )),
          child: child,
        );
      },
      transitionDuration: AppAnimations.pageTransitionDuration,
    );
  }

  static Route<T> scaleTransition<T extends Object?>(
    Widget page,
  ) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.smoothCurve,
          )),
          child: child,
        );
      },
      transitionDuration: AppAnimations.pageTransitionDuration,
    );
  }

  static Route<T> heroTransition<T extends Object?>(
    Widget page,
    String heroTag,
  ) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Hero(
          tag: heroTag,
          child: child,
        );
      },
      transitionDuration: AppAnimations.pageTransitionDuration,
    );
  }
}

