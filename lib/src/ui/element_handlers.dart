import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/common_types.dart';
import 'package:flutter_flow_chart/src/dashboard.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/handler_widget.dart';

class ElementHandlers<T extends FlowElement> extends StatelessWidget {
  const ElementHandlers({
    required this.dashboard,
    required this.element,
    required this.handlerSize,
    required this.child,
    required this.onHandlerPressed,
    required this.onHandlerSecondaryTapped,
    required this.onHandlerLongPressed,
    required this.onHandlerSecondaryLongTapped,
    super.key,
  });

  final Dashboard dashboard;
  final T element;
  final Widget child;
  final double handlerSize;
  final HandlerCallback? onHandlerPressed;
  final HandlerCallback? onHandlerLongPressed;
  final HandlerCallback? onHandlerSecondaryTapped;
  final HandlerCallback? onHandlerSecondaryLongTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width + handlerSize,
      height: element.size.height + handlerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          for (int i = 0; i < element.handlers.length; i++)
            _ElementHandler(
              element: element,
              handler: element.handlers[i],
              dashboard: dashboard,
              handlerSize: handlerSize,
              onHandlerPressed: onHandlerPressed,
              onHandlerSecondaryTapped: onHandlerSecondaryTapped,
              onHandlerLongPressed: onHandlerLongPressed,
              onHandlerSecondaryLongTapped: onHandlerSecondaryLongTapped,
            ),
        ],
      ),
    );
  }
}

class _ElementHandler<T extends FlowElement> extends StatelessWidget {
  const _ElementHandler({
    required this.element,
    required this.handler,
    required this.dashboard,
    required this.handlerSize,
    required this.onHandlerPressed,
    required this.onHandlerSecondaryTapped,
    required this.onHandlerLongPressed,
    required this.onHandlerSecondaryLongTapped,
  });

  final T element;
  final Handler handler;
  final Dashboard dashboard;
  final double handlerSize;
  final HandlerCallback? onHandlerPressed;
  final HandlerCallback? onHandlerSecondaryTapped;
  final HandlerCallback? onHandlerLongPressed;
  final HandlerCallback? onHandlerSecondaryLongTapped;

  @override
  Widget build(BuildContext context) {
    var isDragging = false;

    Alignment alignment = _getAlignmentForHandler(handler);

    var tapDown = Offset.zero;
    var secondaryTapDown = Offset.zero;
    return Align(
      alignment: alignment,
      child: DragTarget<Map<dynamic, dynamic>>(
        onWillAcceptWithDetails: (details) {
          _updateDrawingArrow(alignment);
          return element != details.data['srcElement'] as FlowElement;
        },
        onAcceptWithDetails: (details) {
          dashboard.addNextById(
            details.data['srcElement'] as FlowElement,
            element.id,
            DrawingArrow.instance.params.copyWith(
              endArrowPosition: alignment,
            ),
          );
        },
        onLeave: (data) {
          _resetDrawingArrow();
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable(
            feedback: const SizedBox.shrink(),
            feedbackOffset: dashboard.handlerFeedbackOffset,
            childWhenDragging: HandlerWidget(
              width: handlerSize,
              height: handlerSize,
              backgroundColor: Colors.blue,
            ),
            data: {
              'srcElement': element,
              'alignment': alignment,
            },
            child: _buildGestureDetector(context, tapDown, secondaryTapDown),
            onDragUpdate: (details) {
              _handleDragUpdate(details, isDragging);
              isDragging = true;
            },
            onDragEnd: (details) {
              DrawingArrow.instance.reset();
              isDragging = false;
            },
          );
        },
      ),
    );
  }

  Alignment _getAlignmentForHandler(Handler handler) {
    switch (handler) {
      case Handler.topCenter:
        return Alignment.topCenter;
      case Handler.bottomCenter:
        return Alignment.bottomCenter;
      case Handler.leftCenter:
        return Alignment.centerLeft;
      case Handler.rightCenter:
        return Alignment.centerRight;
    }
  }

  void _updateDrawingArrow(Alignment alignment) {
    DrawingArrow.instance.setParams(
      DrawingArrow.instance.params.copyWith(
        endArrowPosition: alignment,
        style: dashboard.defaultArrowStyle,
      ),
    );
  }

  void _resetDrawingArrow() {
    DrawingArrow.instance.setParams(
      DrawingArrow.instance.params.copyWith(
        endArrowPosition: Alignment.center,
        style: dashboard.defaultArrowStyle,
      ),
    );
  }

  Widget _buildGestureDetector(
      BuildContext context, Offset tapDown, Offset secondaryTapDown) {
    return GestureDetector(
      onTapDown: (details) =>
          tapDown = details.globalPosition - dashboard.position,
      onSecondaryTapDown: (details) =>
          secondaryTapDown = details.globalPosition - dashboard.position,
      onTap: () => onHandlerPressed?.call(context, tapDown, handler, element),
      onSecondaryTap: () => onHandlerSecondaryTapped?.call(
          context, secondaryTapDown, handler, element),
      onLongPress: () =>
          onHandlerLongPressed?.call(context, tapDown, handler, element),
      onSecondaryLongPress: () => onHandlerSecondaryLongTapped?.call(
          context, secondaryTapDown, handler, element),
      child: HandlerWidget(
        width: handlerSize,
        height: handlerSize,
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, bool isDragging) {
    if (!isDragging) {
      DrawingArrow.instance.params = ArrowParams(
        startArrowPosition: _getAlignmentForHandler(handler),
        endArrowPosition: Alignment.center,
      );
      DrawingArrow.instance.from = details.globalPosition - dashboard.position;
    }
    DrawingArrow.instance.setTo(
      details.globalPosition -
          dashboard.position +
          dashboard.handlerFeedbackOffset,
    );
  }
}
