import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// AR Navigation screen, cloned from the Figma "AR" frame (node 17:382).
///
/// This is a **static** clone only — there is no live AR/navigation logic. The
/// real experience will be wired to Unity + a backend later. The X button
/// closes back to the Map.
class ArNavigationScreen extends StatelessWidget {
  const ArNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5A623),
              Color(0xFFF9C173),
              Color(0xFFFBEAD2),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.35, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              const Spacer(),
              _arPet(),
              const Spacer(),
              _miniMapSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/map'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x4DFFFFFF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: const Icon(Icons.close, size: 22, color: AppColors.surface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _etaBanner()),
        ],
      ),
    );
  }

  Widget _etaBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.petInk,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: AppColors.yellow, shape: BoxShape.circle),
            child: const Icon(Icons.schedule, size: 15, color: AppColors.petInk),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('ETA',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Color(0xCCFFFFFF))),
              Text('3 min',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface)),
            ],
          ),
          const Spacer(),
          Container(
            width: 1,
            height: 28,
            color: const Color(0x33FFFFFF),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('NEXT',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Color(0xCCFFFFFF))),
              Text('GO STRAIGHT',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _arPet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.petInk, width: 2),
            color: const Color(0x22FFFFFF),
          ),
          child: const Icon(Icons.pets, size: 22, color: AppColors.petInk),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Icon(Icons.arrow_upward, size: 28, color: AppColors.petInk),
        const SizedBox(height: AppSpacing.sm),
        Image.asset('assets/images/shark_dive.png', width: 150),
        Container(
          width: 110,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0x22000000),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ],
    );
  }

  Widget _miniMapSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2D Top-Down',
                  style: TextStyle(fontSize: 16, color: AppColors.petInk)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F4),
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.danger),
                    SizedBox(width: 6),
                    Text('Live',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.petInk)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _miniMap(),
        ],
      ),
    );
  }

  Widget _miniMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DashedRoutePainter()),
          ),
          // Destination dot (top-right).
          const Positioned(
            top: 24,
            right: 28,
            child: Icon(Icons.circle, size: 14, color: AppColors.petInk),
          ),
          // "Go Straight!" tag (left).
          Positioned(
            left: 16,
            bottom: 48,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.petInk,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('Go Straight!',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface)),
            ),
          ),
          // Pet marker (bottom).
          Positioned(
            left: 92,
            bottom: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: AppColors.yellow, shape: BoxShape.circle),
              child: const Icon(Icons.pets, size: 15, color: AppColors.petInk),
            ),
          ),
          // Recenter & layers controls.
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _mapControl(Icons.my_location),
                const SizedBox(height: AppSpacing.sm),
                _mapControl(Icons.layers_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControl(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.petInk),
    );
  }
}

/// Paints the dashed yellow L-shaped route in the AR mini-map.
class _DashedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.yellow
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final corner = Offset(size.width * 0.27, 32);
    final start = Offset(size.width * 0.27, size.height - 24);
    final end = Offset(size.width - 32, 32);

    _dashLine(canvas, start, corner, paint);
    _dashLine(canvas, corner, end, paint);
  }

  void _dashLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 8.0;
    const gap = 6.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final s = a + dir * d;
      final e = a + dir * (d + dash).clamp(0, total);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
