// Run with: dart run tool/generate_icon.dart
// Generates assets/icons/voxpilot_logo_icon.png (1024x1024)
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() async {
  // Bootstrap Flutter bindings for painting
  WidgetsFlutterBinding.ensureInitialized();

  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  _drawIcon(canvas, size);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final outDir = Directory('assets/icons');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  File('assets/icons/voxpilot_logo_icon.png').writeAsBytesSync(bytes);
  print(
    '✅  Written: assets/icons/voxpilot_logo_icon.png (1024x1024)',
  ); // ignore: avoid_print
}

void _drawIcon(Canvas canvas, double size) {
  final paint = Paint()..isAntiAlias = true;

  // ── Background rounded rect ──────────────────────────────────────────────
  final bgRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(230),
  );
  paint.shader = ui.Gradient.linear(Offset.zero, Offset(size, size), [
    const Color(0xFF1A237E),
    const Color(0xFF5C6BC0),
  ]);
  canvas.drawRRect(bgRect, paint);
  paint.shader = null;

  // ── Sound wave bars — left ───────────────────────────────────────────────
  _drawWaveBar(canvas, 168, 450, 28, 124);
  _drawWaveBar(canvas, 214, 400, 28, 224);
  _drawWaveBar(canvas, 260, 432, 28, 160);

  // ── Sound wave bars — right ──────────────────────────────────────────────
  _drawWaveBar(canvas, 736, 450, 28, 124);
  _drawWaveBar(canvas, 782, 400, 28, 224);
  _drawWaveBar(canvas, 828, 432, 28, 160);

  // ── Mic capsule (white outer) ────────────────────────────────────────────
  paint.color = Colors.white;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(432, 230, 160, 270),
      const Radius.circular(80),
    ),
    paint,
  );

  // ── Mic capsule (cyan inner) ─────────────────────────────────────────────
  paint.shader = ui.Gradient.linear(
    const Offset(512, 250),
    const Offset(512, 480),
    [const Color(0xFF80DEEA), const Color(0xFF00ACC1)],
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(452, 250, 120, 230),
      const Radius.circular(60),
    ),
    paint,
  );
  paint.shader = null;

  // ── Mic grille lines ─────────────────────────────────────────────────────
  final grillePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  for (final y in [310.0, 338.0, 366.0, 394.0, 422.0]) {
    canvas.drawLine(Offset(477, y), Offset(547, y), grillePaint);
  }

  // ── Mic stand arc ────────────────────────────────────────────────────────
  final standPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 28
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final arcPath = Path()
    ..moveTo(360, 490)
    ..quadraticBezierTo(360, 650, 512, 650)
    ..quadraticBezierTo(664, 650, 664, 490);
  canvas.drawPath(arcPath, standPaint);

  // ── Mic stand vertical ───────────────────────────────────────────────────
  canvas.drawLine(const Offset(512, 650), const Offset(512, 740), standPaint);

  // ── Mic stand base ───────────────────────────────────────────────────────
  canvas.drawLine(const Offset(400, 740), const Offset(624, 740), standPaint);

  // ── AI accent dot ────────────────────────────────────────────────────────
  paint.color = const Color(0xFF00E5FF);
  canvas.drawCircle(const Offset(596, 284), 28, paint);
  paint.color = Colors.white;
  canvas.drawCircle(const Offset(596, 284), 16, paint);
}

void _drawWaveBar(Canvas canvas, double x, double y, double w, double h) {
  final paint = Paint()
    ..shader = ui.Gradient.linear(Offset(x, y), Offset(x, y + h), [
      const Color(0xFF80DEEA),
      const Color(0xFF00ACC1),
    ])
    ..isAntiAlias = true;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(14),
    ),
    paint,
  );
}
