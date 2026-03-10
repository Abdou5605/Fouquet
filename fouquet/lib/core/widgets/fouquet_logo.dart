import 'package:flutter/material.dart';
import 'package:fouquet/core/resources/app_logos.dart';

enum LogoVariant { full, white }

class FouquetLogo extends StatelessWidget {
  final LogoVariant variant;
  final double? width;
  final double? height;

  const FouquetLogo({
    super.key,
    this.variant = LogoVariant.full,
    this.width,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final path = variant == LogoVariant.white
        ? AppLogos
              .fullWhite // image 2 — fond sombre
        : AppLogos.full; // image 1 — fond clair

    return Image.asset(path, width: width, height: height, fit: BoxFit.contain);
  }
}
