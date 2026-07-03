import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.height = 72,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height,
      width: width ?? height * 2.5,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        width: width ?? height,
        child: Icon(
          Icons.image_outlined,
          size: height * 0.45,
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
