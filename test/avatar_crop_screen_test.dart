import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navipet/screens/avatar_crop_screen.dart';

/// A small landscape image: red left half, blue right half.
Future<ui.Image> _testImage() {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawRect(
      const Rect.fromLTWH(0, 0, 40, 20),
      Paint()..color = const Color(0xFFFF0000),
    )
    ..drawRect(
      const Rect.fromLTWH(20, 0, 20, 20),
      Paint()..color = const Color(0xFF0000FF),
    );
  return recorder.endRecording().toImage(40, 20);
}

Future<Uint8List> _png(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// The chunk types of a PNG, in order.
List<String> _chunks(Uint8List png) {
  final view = ByteData.sublistView(png);
  final types = <String>[];
  var at = 8; // Past the signature.
  while (at + 8 <= png.length) {
    final length = view.getUint32(at);
    types.add(ascii.decode(png.sublist(at + 4, at + 8)));
    at += 12 + length;
  }
  return types;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

/// Inserts an `eXIf` chunk (EXIF with a GPS marker) right after IHDR.
Uint8List _withExif(Uint8List png) {
  final ihdrEnd = 8 + 12 + ByteData.sublistView(png).getUint32(8);
  final type = ascii.encode('eXIf');
  final data = [
    ...ascii.encode('MM'), 0, 42, 0, 0, 0, 8, // TIFF header
    ...ascii.encode('GPS 33.7838N 118.1141W'),
  ];
  final chunk = BytesBuilder()
    ..add((ByteData(4)..setUint32(0, data.length)).buffer.asUint8List())
    ..add(type)
    ..add(data)
    ..add(
      (ByteData(
        4,
      )..setUint32(0, _crc32([...type, ...data]))).buffer.asUint8List(),
    );
  return Uint8List.fromList([
    ...png.sublist(0, ihdrEnd),
    ...chunk.takeBytes(),
    ...png.sublist(ihdrEnd),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ui.Image image;
  late Completer<Uint8List?> result;

  Future<void> openCropScreen(WidgetTester tester) async {
    await tester.runAsync(() async => image = await _testImage());
    result = Completer<Uint8List?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result.complete(
              await Navigator.of(context).push<Uint8List>(
                MaterialPageRoute(
                  builder: (_) => AvatarCropScreen(image: image),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the guide and returns null on cancel', (tester) async {
    await openCropScreen(tester);

    expect(find.text('Drag and pinch to position your photo'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result.future, isNull);
    image.dispose();
  });

  testWidgets('returns a 512 px square PNG on done', (tester) async {
    await openCropScreen(tester);

    // Drag right: the crop moves over the red half.
    await tester.dragFrom(
      tester.getCenter(find.byType(AvatarCropScreen)),
      const Offset(400, 0),
    );
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // The encode was started from the fake-async zone: let real time pass
    // for the engine, then pump so its continuations run.
    for (var i = 0; i < 100 && !result.isCompleted; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final bytes = await result.future;

    expect(bytes, isNotNull);
    expect(bytes!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
    final decoded = await tester.runAsync(() async {
      final output = (await decodeAvatarImage(bytes))!;
      final pixels = await output.toByteData();
      final size = Size(output.width.toDouble(), output.height.toDouble());
      output.dispose();
      return (size, pixels!);
    });
    expect(decoded!.$1, const Size(512, 512));
    // Top-left pixel is red: the drag panned onto the left half.
    expect(decoded.$2.getUint8(0), greaterThan(200));
    expect(decoded.$2.getUint8(2), lessThan(50));
    image.dispose();
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('re-encoding drops EXIF metadata from the source file', () async {
    final source = await _testImage();
    final input = _withExif(await _png(source));
    source.dispose();
    expect(_chunks(input), contains('eXIf'));

    final decoded = await decodeAvatarImage(input);
    expect(decoded, isNotNull);
    final output = await renderAvatarCrop(
      decoded!,
      const Rect.fromLTWH(10, 0, 20, 20),
    );
    decoded.dispose();

    final chunks = _chunks(output);
    expect(chunks, isNot(contains('eXIf')));
    // The engine's encoder writes only image-format chunks (observed:
    // IHDR, sBIT, sRGB, IDAT, IEND): no eXIf, text or time metadata.
    expect(
      chunks.toSet().difference({'IHDR', 'sBIT', 'sRGB', 'IDAT', 'IEND'}),
      isEmpty,
      reason: 'chunks: $chunks',
    );
    expect(ascii.decode(output, allowInvalid: true), isNot(contains('GPS')));
  });

  test('a noisy 512 px crop stays far below the 5 MB upload limit', () async {
    // Random pixels are the worst case for PNG compression.
    final random = math.Random(1);
    final pixels = Uint8List.fromList(
      List.generate(
        512 * 512 * 4,
        (i) => i % 4 == 3 ? 255 : random.nextInt(256),
      ),
    );
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      512,
      512,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final noise = await completer.future;
    final output = await renderAvatarCrop(
      noise,
      const Rect.fromLTWH(0, 0, 512, 512),
    );
    noise.dispose();

    expect(output.length, lessThan(5 * 1024 * 1024 ~/ 4));
  });

  test('undecodable bytes decode to null', () async {
    expect(await decodeAvatarImage(Uint8List.fromList([1, 2, 3, 4])), isNull);
  });
}
