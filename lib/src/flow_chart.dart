import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/draw_arrow.dart';
import 'package:flutter_flow_chart/src/ui/element_widget.dart';
import 'package:flutter_flow_chart/src/ui/grid_background.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';
import 'package:flutter_flow_chart/src/common_types.dart';

class FlowChart<T extends FlowElement> extends StatefulWidget {
  const FlowChart({
    required this.dashboard,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onDashboardTapped,
    this.onDashboardSecondaryTapped,
    this.onDashboardLongTapped,
    this.onDashboardSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
    this.onPivotPressed,
    this.onPivotSecondaryPressed,
    this.onScaleUpdate,
    this.onNewConnection,
    super.key,
  });

  final DashboardCallback? onDashboardTapped;
  final DashboardCallback? onDashboardLongTapped;
  final DashboardCallback? onDashboardSecondaryTapped;
  final DashboardCallback? onDashboardSecondaryLongTapped;
  final ElementCallback? onElementPressed;
  final ElementCallback? onElementSecondaryTapped;
  final ElementCallback? onElementLongPressed;
  final ElementCallback? onElementSecondaryLongTapped;
  final PivotCallback? onPivotPressed;
  final PivotCallback? onPivotSecondaryPressed;
  final HandlerCallback? onHandlerPressed;
  final HandlerCallback? onHandlerSecondaryTapped;
  final HandlerCallback? onHandlerSecondaryLongTapped;
  final HandlerCallback? onHandlerLongPressed;
  final ConnectionListener? onNewConnection;
  final Dashboard<T> dashboard;
  final void Function(double scale)? onScaleUpdate;

  @override
  State<FlowChart> createState() => _FlowChartState();
}

class _FlowChartState<T extends FlowElement> extends State<FlowChart<T>> {
  @override
  void initState() {
    super.initState();
    widget.dashboard.addListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.addOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
    if (widget.onNewConnection != null) {
      widget.dashboard.addConnectionListener(widget.onNewConnection!);
    }
  }

  @override
  void dispose() {
    widget.dashboard.removeListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.removeOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  double _oldScaleUpdateDelta = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_updateDashboardPosition);

    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    final gridKey = GlobalKey();
    var tapDownPos = Offset.zero;
    var secondaryTapDownPos = Offset.zero;

    return ClipRect(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildGridBackground(gridKey, tapDownPos, secondaryTapDownPos),
          ..._buildElements(),
          ..._buildArrows(),
          ..._buildSegmentHandlers(),
          DrawingArrowWidget(style: widget.dashboard.defaultArrowStyle),
        ],
      ),
    );
  }

  Widget _buildGridBackground(
    GlobalKey gridKey,
    Offset tapDownPos,
    Offset secondaryTapDownPos,
  ) {
    return Positioned.fill(
      child: GestureDetector(
        onTapDown: (details) => tapDownPos = details.localPosition,
        onSecondaryTapDown: (details) =>
            secondaryTapDownPos = details.localPosition,
        onTap: () =>
            widget.onDashboardTapped?.call(gridKey.currentContext!, tapDownPos),
        onLongPress: () => widget.onDashboardLongTapped
            ?.call(gridKey.currentContext!, tapDownPos),
        onSecondaryTap: () => widget.onDashboardSecondaryTapped
            ?.call(gridKey.currentContext!, secondaryTapDownPos),
        onSecondaryLongPress: () => widget.onDashboardSecondaryLongTapped
            ?.call(gridKey.currentContext!, secondaryTapDownPos),
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: GridBackground(
          key: gridKey,
          params: widget.dashboard.gridBackgroundParams,
        ),
      ),
    );
  }

  List<Widget> _buildElements() {
    return widget.dashboard.elements.map((element) {
      return ElementWidget<T>(
        key: ValueKey(element.id),
        dashboard: widget.dashboard,
        element: element,
        onElementPressed: widget.onElementPressed,
        onElementSecondaryTapped: widget.onElementSecondaryTapped,
        onElementLongPressed: widget.onElementLongPressed,
        onElementSecondaryLongTapped: widget.onElementSecondaryLongTapped,
        onHandlerPressed: widget.onHandlerPressed,
        onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
        onHandlerLongPressed: widget.onHandlerLongPressed,
        onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
      );
    }).toList();
  }

  List<Widget> _buildArrows() {
    return widget.dashboard.elements.expand((element) {
      return element.next.map((connection) {
        final destElement =
            widget.dashboard.findElementById(connection.destElementId);
        if (destElement == null) return const SizedBox.shrink();
        return DrawArrow(
          key: ValueKey('${element.id}-${destElement.id}'),
          srcElement: element,
          destElement: destElement,
          arrowParams: connection.arrowParams,
          pivots: connection.pivots,
        );
      });
    }).toList();
  }

  List<Widget> _buildSegmentHandlers() {
    return widget.dashboard.elements.expand((element) {
      return element.next
          .where((connection) =>
              connection.arrowParams.style == ArrowStyle.segmented)
          .expand((connection) {
        return connection.pivots.map((pivot) {
          return SegmentHandler(
            key: ValueKey(
                '${element.id}-${connection.destElementId}-${pivot.hashCode}'),
            pivot: pivot,
            dashboard: widget.dashboard,
            onPivotPressed: widget.onPivotPressed,
            onPivotSecondaryPressed: widget.onPivotSecondaryPressed,
          );
        });
      });
    }).toList();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1) {
      widget.dashboard.setZoomFactor(
        details.scale + _oldScaleUpdateDelta,
        focalPoint: details.focalPoint,
      );
    }

    widget.dashboard.setDashboardPosition(
      widget.dashboard.position + details.focalPointDelta,
    );
    for (final element in widget.dashboard.elements) {
      element.position += details.focalPointDelta;
      for (final conn in element.next) {
        for (final pivot in conn.pivots) {
          pivot.pivot += details.focalPointDelta;
        }
      }
    }

    widget.dashboard.gridBackgroundParams.offset = details.focalPointDelta;
    setState(() {});
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _oldScaleUpdateDelta = widget.dashboard.zoomFactor - 1;
  }

  void _updateDashboardPosition(Duration timeStamp) {
    if (mounted) {
      final object = context.findRenderObject() as RenderBox?;
      if (object != null) {
        final translation = object.getTransformTo(null).getTranslation();
        final size = object.semanticBounds.size;
        final position = Offset(translation.x, translation.y);

        widget.dashboard.setDashboardSize(size);
        widget.dashboard.setDashboardPosition(position);
      }
    }
  }
}

class DrawingArrowWidget extends StatefulWidget {
  const DrawingArrowWidget({required this.style, super.key});

  final ArrowStyle style;

  @override
  State<DrawingArrowWidget> createState() => _DrawingArrowWidgetState();
}

class _DrawingArrowWidgetState extends State<DrawingArrowWidget> {
  @override
  void initState() {
    super.initState();
    DrawingArrow.instance.addListener(_arrowChanged);
  }

  @override
  void dispose() {
    DrawingArrow.instance.removeListener(_arrowChanged);
    super.dispose();
  }

  void _arrowChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (DrawingArrow.instance.isZero()) return const SizedBox.shrink();
    return CustomPaint(
      painter: ArrowPainter(
        params: DrawingArrow.instance.params,
        from: DrawingArrow.instance.from,
        to: DrawingArrow.instance.to,
      ),
    );
  }
}
