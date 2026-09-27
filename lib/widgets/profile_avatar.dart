import 'package:flutter/material.dart';

/// A circular avatar that shows the profile photo at [imageUrl] when there is
/// one, and the first initial of [name] on [color] otherwise or while the
/// photo is loading or broken.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.color,
    required this.size,
    this.imageUrl,
    this.initialStyle,
    this.onImageError,
  });

  final String name;
  final Color color;
  final double size;

  /// A signed URL from the NaviPet backend; `null` shows the initial.
  final String? imageUrl;
  final TextStyle? initialStyle;

  /// Called with the failing URL, e.g. so an expired signed URL is refreshed.
  /// Runs during build, so it must not notify listeners synchronously.
  final ValueChanged<String>? onImageError;

  @override
  Widget build(BuildContext context) {
    final initial = Center(
      child: Text(
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
        style:
            initialStyle ??
            TextStyle(
              fontSize: size * .36,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    final url = imageUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? initial
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : initial,
              errorBuilder: (context, error, stackTrace) {
                onImageError?.call(url);
                return initial;
              },
            ),
    );
  }
}
