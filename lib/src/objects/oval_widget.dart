import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

class OvalWidget extends StatelessWidget {
  const OvalWidget({
    required this.element,
    required this.child,
    super.key,
  });

  final FlowElement element;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          CustomPaint(
            size: element.size,
            painter: _OvalPainter(element: element),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalPainter extends CustomPainter {
  _OvalPainter({required this.element});

  final FlowElement element;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = element.backgroundColor;

    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path, paint);

    paint
      ..strokeWidth = element.borderThickness
      ..color = element.borderColor
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
