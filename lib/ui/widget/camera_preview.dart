import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.minAvailableZoom,
    required this.maxAvailableZoom,
    this.borderRadius = 60,
  });

  final CameraController controller;
  final double minAvailableZoom;
  final double maxAvailableZoom;

  final double borderRadius;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  double _currentScale = 1;
  double _baseScale = 1;

  int _pointers = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CameraPreview(
          widget.controller,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onTapDown: (TapDownDetails details) =>
                    onViewFinderTap(details, constraints),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(widget.minAvailableZoom, widget.maxAvailableZoom);

    await widget.controller.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    widget.controller.setExposurePoint(offset);
    widget.controller.setFocusPoint(offset);
  }
}
