import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LoadingAnimations {
  // Shimmer loading for cards
  static Widget shimmerCard({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.border,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),
    );
  }

  // Shimmer list
  static Widget shimmerList({int itemCount = 3}) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: shimmerCard(),
        ),
      ),
    );
  }
}

