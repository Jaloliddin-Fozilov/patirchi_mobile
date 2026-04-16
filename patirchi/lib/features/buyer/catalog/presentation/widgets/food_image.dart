import 'package:flutter/material.dart';

class FoodImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final double borderRadius;
  final BoxShape shape;

  const FoodImage({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.placeholderColor,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (shape == BoxShape.circle) {
        return ClipOval(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: _loadingBuilder,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: _loadingBuilder,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _loadingBuilder(
      BuildContext ctx, Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    return _placeholder(showLoading: true);
  }

  Widget _placeholder({bool showLoading = false}) {
    final hsl = HSLColor.fromColor(placeholderColor);
    final darkTone = hsl
        .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    final decoration = shape == BoxShape.circle
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [placeholderColor, darkTone],
              center: Alignment.topLeft,
              radius: 1.2,
            ),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [placeholderColor, darkTone],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );

    return Container(
      decoration: decoration,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              )
            : Icon(
                fallbackIcon,
                size: shape == BoxShape.circle ? 24 : 36,
                color: Colors.white.withValues(alpha: 0.7),
              ),
      ),
    );
  }
}
