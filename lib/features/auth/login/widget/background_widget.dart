import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: ColorConstants.darkBackground,
      child: Stack(
        children: [
          // Orange wave top-left
          Positioned(
            top: -80,
            left: -80,
            child: CustomPaint(
              size: Size(size.width * 0.8, size.height * 0.35),
              painter: _OrangeWavePainter(),
            ),
          ),
          // Blue wave bottom-right
          Positioned(
            bottom: -60,
            right: -60,
            child: CustomPaint(
              size: Size(size.width * 0.7, size.height * 0.35),
              painter: _BlueWavePainter(),
            ),
          ),
          // Top-left dot pattern
          Positioned(
            top: 100,
            left: 20,
            child: _DotPattern(color: ColorConstants.darkPrimaryIcon.withOpacity(0.4)),
          ),
          // Bottom-right dot pattern
          Positioned(
            bottom: 60,
            right: 20,
            child: _DotPattern(color: ColorConstants.secondaryBlue.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

class _OrangeWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          ColorConstants.darkPrimaryIcon.withOpacity(0.6),
          ColorConstants.darkPrimaryIcon.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.3, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.8, 0, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlueWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ColorConstants.secondaryBlue.withOpacity(0.5),
          ColorConstants.secondaryBlue.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.7, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.1, size.width, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotPattern extends StatelessWidget {
  final Color color;
  const _DotPattern({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
