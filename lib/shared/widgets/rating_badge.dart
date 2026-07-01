import 'package:flutter/material.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';

/// Small star rating badge used on cards and detail pages
class RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;

  const RatingBadge({super.key, required this.rating, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final text = rating > 0 ? rating.toStringAsFixed(1) : 'N/A';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppTheme.starColor, size: fontSize + 2),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.starColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
