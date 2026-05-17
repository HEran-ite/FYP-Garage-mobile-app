import 'package:flutter/material.dart';

/// Full CarCare logo (icon + wordmark) for auth screens.
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
