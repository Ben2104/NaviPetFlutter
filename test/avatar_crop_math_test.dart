import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/data/avatar_crop_math.dart';

// A 2:1 landscape photo under a 300 px circle: the minimum scale makes its
// 1000 px height span the circle, so 0.3 display px per image px.
const _image = Size(2000, 1000);
const _diameter = 300.0;

void main() {
  test('minimum scale fits the shorter side to the circle', () {
    expect(minAvatarCropScale(_image, _diameter), closeTo(0.3, 1e-9));
    expect(minAvatarCropScale(const Size(800, 1600), 400), closeTo(0.5, 1e-9));
  });

  test('starts centred at the minimum scale', () {
    final t = AvatarCropTransform.initial(_image, _diameter);
    expect(t.scale, closeTo(0.3, 1e-9));
    expect(t.offset, Offset.zero);
    _expectRect(
      t.sourceRect(_image, _diameter),
      const Rect.fromLTWH(500, 0, 1000, 1000),
    );
  });

  test('zooming in shrinks the centred source square', () {
    const t = AvatarCropTransform(scale: 0.6, offset: Offset.zero);
    _expectRect(
      t.sourceRect(_image, _diameter),
      const Rect.fromLTWH(750, 250, 500, 500),
    );
  });

  test('panning moves the source square the opposite way', () {
    // Image dragged 60 px right and 30 px up: the crop sees further left
    // and further down in the image.
    const t = AvatarCropTransform(scale: 0.6, offset: Offset(60, -30));
    _expectRect(
      t.sourceRect(_image, _diameter),
      const Rect.fromLTWH(650, 300, 500, 500),
    );
  });

  test('clamps the scale between the minimum and 5x', () {
    expect(
      const AvatarCropTransform(
        scale: 0.1,
        offset: Offset.zero,
      ).clamped(_image, _diameter).scale,
      closeTo(0.3, 1e-9),
    );
    expect(
      const AvatarCropTransform(
        scale: 9,
        offset: Offset.zero,
      ).clamped(_image, _diameter).scale,
      closeTo(1.5, 1e-9),
    );
  });

  test('clamps the pan so the image always covers the circle', () {
    // At 0.3 the image is 600x300 on screen: 150 px of slack sideways, none
    // vertically.
    final t = const AvatarCropTransform(
      scale: 0.3,
      offset: Offset(500, 40),
    ).clamped(_image, _diameter);
    expect(t.offset, const Offset(150, 0));
    _expectRect(
      t.sourceRect(_image, _diameter),
      const Rect.fromLTWH(0, 0, 1000, 1000),
    );

    final left = const AvatarCropTransform(
      scale: 0.3,
      offset: Offset(-9999, -9999),
    ).clamped(_image, _diameter);
    expect(left.offset, const Offset(-150, 0));
    _expectRect(
      left.sourceRect(_image, _diameter),
      const Rect.fromLTWH(1000, 0, 1000, 1000),
    );
  });

  test('a drag pans, clamped to the covering limits', () {
    final t = AvatarCropTransform.initial(_image, _diameter).gesture(
      focalStart: Offset.zero,
      focal: const Offset(10, 5),
      gestureScale: 1,
      image: _image,
      diameter: _diameter,
    );
    expect(t.offset, const Offset(10, 0));
  });

  test('a pinch keeps the image point under the fingers in place', () {
    const focal = Offset(100, 0);
    final start = AvatarCropTransform.initial(_image, _diameter);
    final t = start.gesture(
      focalStart: focal,
      focal: focal,
      gestureScale: 2,
      image: _image,
      diameter: _diameter,
    );
    expect(t.scale, closeTo(0.6, 1e-9));
    expect(t.offset.dx, closeTo(-100, 1e-9));
    // Image x under the focal point, before and after.
    double imageX(AvatarCropTransform t) =>
        _image.width / 2 + (focal.dx - t.offset.dx) / t.scale;
    expect(imageX(t), closeTo(imageX(start), 1e-6));
  });

  test('a pinch past the limits stops at 5x', () {
    final t = AvatarCropTransform.initial(_image, _diameter).gesture(
      focalStart: Offset.zero,
      focal: Offset.zero,
      gestureScale: 50,
      image: _image,
      diameter: _diameter,
    );
    expect(t.scale, closeTo(1.5, 1e-9));
    expect(t.sourceRect(_image, _diameter).width, closeTo(200, 1e-9));
  });
}

void _expectRect(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 1e-6), reason: 'left');
  expect(actual.top, closeTo(expected.top, 1e-6), reason: 'top');
  expect(actual.width, closeTo(expected.width, 1e-6), reason: 'width');
  expect(actual.height, closeTo(expected.height, 1e-6), reason: 'height');
}
