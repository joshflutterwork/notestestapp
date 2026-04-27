import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

/// A reusable gradient background container that applies the app's
/// standard top-to-bottom gradient (bgGradientStart → bgGradientEnd).
class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
        ),
      ),
      child: child,
    );
  }
}
