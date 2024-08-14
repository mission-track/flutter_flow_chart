import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/common_types.dart';
import 'package:flutter_flow_chart/src/objects/diamond_widget.dart';
import 'package:flutter_flow_chart/src/objects/hexagon_widget.dart';
import 'package:flutter_flow_chart/src/objects/oval_widget.dart';
import 'package:flutter_flow_chart/src/objects/parallelogram_widget.dart';
import 'package:flutter_flow_chart/src/objects/rectangle_widget.dart';
import 'package:flutter_flow_chart/src/objects/storage_widget.dart';
import 'package:flutter_flow_chart/src/ui/element_handlers.dart';
import 'package:flutter_flow_chart/src/ui/resize_widget.dart';

class ElementWidget<T extends FlowElement> extends StatefulWidget {
  const ElementWidget({
    required this.dashboard,
    required this.element,
    super.key,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onElementMoved,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
  });

  final Dashboard<T> dashboard;
  final T element;
  final ElementCallback? onElementPressed;
  final ElementCallback? onElementSecondaryTapped;
  final ElementCallback? onElementLongPressed;
  final ElementCallback? onElementSecondaryLongTapped;
  final ElementCallback? onElementMoved;
  final HandlerCallback? onHandlerPressed;
  final HandlerCallback? onHandlerSecondaryTapped;
  final HandlerCallback? onHandlerLongPressed;
  final HandlerCallback? onHandlerSecondaryLongTapped;

  @override
  State<ElementWidget<T>> createState() => _ElementWidgetState<T>();
}

class _ElementWidgetState<T extends FlowElement> extends State<ElementWidget<T>> {
  Offset delta = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.element.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.element.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget elementContent = widget.element
        .builder(context, widget.element.data, widget.element.kind);

    Widget shapeWidget;
    switch (widget.element.kind) {
      case ElementKind.diamond:
        shapeWidget =
            DiamondWidget(element: widget.element, child: elementContent);
      case ElementKind.storage:
        shapeWidget =
            StorageWidget(element: widget.element, child: elementContent);
      case ElementKind.oval:
        shapeWidget =
            OvalWidget(element: widget.element, child: elementContent);
      case ElementKind.parallelogram:
        shapeWidget =
            ParallelogramWidget(element: widget.element, child: elementContent);
      case ElementKind.hexagon:
        shapeWidget =
            HexagonWidget(element: widget.element, child: elementContent);
      case ElementKind.rectangle:
        shapeWidget =
            RectangleWidget(element: widget.element, child: elementContent);
    }

    if (widget.element.isResizing) {
      return Transform.translate(
        offset: widget.element.position,
        child: ResizeWidget(
          element: widget.element,
          dashboard: widget.dashboard,
          child: shapeWidget,
        ),
      );
    }

    shapeWidget = Padding(
      padding: EdgeInsets.all(widget.element.handlerSize / 2),
      child: shapeWidget,
    );

    var tapLocation = Offset.zero;
    var secondaryTapDownPos = Offset.zero;
    return Transform.translate(
      offset: widget.element.position,
      transformHitTests: true,
      child: GestureDetector(
        onTapDown: (details) => tapLocation = details.globalPosition,
        onSecondaryTapDown: (details) =>
            secondaryTapDownPos = details.globalPosition,
        onTap: () {
          widget.onElementPressed?.call(context, tapLocation, widget.element);
        },
        onSecondaryTap: () {
          widget.onElementSecondaryTapped
              ?.call(context, secondaryTapDownPos, widget.element);
        },
        onLongPress: () {
          widget.onElementLongPressed
              ?.call(context, tapLocation, widget.element);
        },
        onSecondaryLongPress: () {
          widget.onElementSecondaryLongTapped
              ?.call(context, secondaryTapDownPos, widget.element);
        },
        child: Listener(
          onPointerDown: (event) {
            delta = event.localPosition;
          },
          child: Draggable<T>(
            data: widget.element,
            dragAnchorStrategy: childDragAnchorStrategy,
            childWhenDragging: const SizedBox.shrink(),
            feedback: Material(
              color: Colors.transparent,
              child: shapeWidget,
            ),
            child: ElementHandlers<T>(
              dashboard: widget.dashboard,
              element: widget.element,
              handlerSize: widget.element.handlerSize,
              onHandlerPressed: widget.onHandlerPressed,
              onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
              onHandlerLongPressed: widget.onHandlerLongPressed,
              onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
              child: shapeWidget,
            ),
            onDragUpdate: (details) {
              widget.element.changePosition(
                details.globalPosition - widget.dashboard.position - delta,
              );
            },
            onDragEnd: (details) {
              final newPosition = details.offset - widget.dashboard.position;
              widget.element.changePosition(newPosition);
              widget.onElementMoved?.call(context, newPosition, widget.element);
            },
          ),
        ),
      ),
    );
  }
}
