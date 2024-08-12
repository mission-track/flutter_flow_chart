import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

class RectangleWidget extends StatelessWidget {
  const RectangleWidget({
    required this.element,
    required this.child,
    super.key,
  });

  final FlowElement element;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: element.backgroundColor,
        boxShadow: [
          if (element.elevation > 0.01)
            BoxShadow(
              color: Colors.grey,
              offset: Offset(element.elevation, element.elevation),
              blurRadius: element.elevation * 1.3,
            ),
        ],
        border: Border.all(
          color: element.borderColor,
          width: element.borderThickness,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child,
          ),
        ),
      ),
    );
  }
}
