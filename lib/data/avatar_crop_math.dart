import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// How far past the smallest covering scale the user may zoom in.
const avatarCropMaxZoom = 5.0;

/// The scale (display pixels per image pixel) at which the image's shorter
/// side exactly spans the crop circle's [diameter].
double minAvatarCropScale(Size image, double diameter) =>
    diameter / math.min(image.width, image.height);

/// Where the image sits under the circular crop guide.
///
/// [scale] is display pixels per image pixel; [offset] is how far the image
/// centre sits from the circle centre, in display pixels. A transform is valid
/// when the image covers the circle's bounding square, since the upload is
/// that square (avatars are clipped to a circle when shown).
@immutable
class AvatarCropTransform {
  const AvatarCropTransform({required this.scale, required this.offset});

  /// Centred, zoomed out as far as the covering constraint allows.
  factory AvatarCropTransform.initial(Size image, double diameter) =>
      AvatarCropTransform(
        scale: minAvatarCropScale(image, diameter),
        offset: Offset.zero,
      );

  final double scale;
  final Offset offset;

  /// Limits the zoom to [minAvatarCropScale]..[avatarCropMaxZoom]× that, then
  /// the pan so no empty space shows inside the crop square.
  AvatarCropTransform clamped(Size image, double diameter) {
    final min = minAvatarCropScale(image, diameter);
    final s = scale.clamp(min, min * avatarCropMaxZoom);
    final maxDx = math.max(0.0, image.width * s / 2 - diameter / 2);
    final maxDy = math.max(0.0, image.height * s / 2 - diameter / 2);
    return AvatarCropTransform(
      scale: s,
      offset: Offset(
        offset.dx.clamp(-maxDx, maxDx),
        offset.dy.clamp(-maxDy, maxDy),
      ),
    );
  }

  /// Applies a pinch/drag that started on this transform. [focalStart] and
  /// [focal] are the gesture's focal point (relative to the circle centre) at
  /// its start and now; [gestureScale] is the pinch scale since its start.
  /// The image point under the fingers stays under the fingers.
  AvatarCropTransform gesture({
    required Offset focalStart,
    required Offset focal,
    required double gestureScale,
    required Size image,
    required double diameter,
  }) {
    final min = minAvatarCropScale(image, diameter);
    final s = (scale * gestureScale).clamp(min, min * avatarCropMaxZoom);
    return AvatarCropTransform(
      scale: s,
      offset: focal - (focalStart - offset) * (s / scale),
    ).clamped(image, diameter);
  }

  /// The crop square in image pixel coordinates.
  Rect sourceRect(Size image, double diameter) {
    final side = math.min(
      diameter / scale,
      math.min(image.width, image.height),
    );
    final left = image.width / 2 - (diameter / 2 + offset.dx) / scale;
    final top = image.height / 2 - (diameter / 2 + offset.dy) / scale;
    // Clamping absorbs floating-point drift at the edges.
    return Rect.fromLTWH(
      left.clamp(0.0, image.width - side),
      top.clamp(0.0, image.height - side),
      side,
      side,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AvatarCropTransform &&
      other.scale == scale &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(scale, offset);

  @override
  String toString() => 'AvatarCropTransform(scale: $scale, offset: $offset)';
}
