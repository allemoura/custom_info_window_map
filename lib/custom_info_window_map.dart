/// A widget based custom info window for google_maps_flutter package.
// ignore_for_file: library_private_types_in_public_api

library custom_info_window;

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Controller to add, update and control the custom info window.
class CustomInfoWindowMapController {
  /// Add custom [Widget] and [Marker]'s [LatLng] to [CustomInfoWindowMap] and make it visible.
  Function(Widget, LatLng)? addInfoWindow;

  /// Notifies [CustomInfoWindowMap] to redraw as per change in position.
  VoidCallback? onCameraMove;

  /// Hides [CustomInfoWindowMap].
  VoidCallback? hideInfoWindow;

  /// Shows [CustomInfoWindowMap].
  VoidCallback? showInfoWindow;

  /// Holds [GoogleMapController] for calculating [CustomInfoWindowMap] position.
  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = null;
    onCameraMove = null;
    hideInfoWindow = null;
    showInfoWindow = null;
    googleMapController = null;
  }
}

/// A stateful widget responsible to create widget based custom info window.
class CustomInfoWindowMap extends StatefulWidget {
  /// A [CustomInfoWindowMapController] to manipulate [CustomInfoWindowMap] state.
  final CustomInfoWindowMapController controller;

  /// Offset to maintain space between [Marker] and [CustomInfoWindowMap].
  final double offset;

  /// Height of [CustomInfoWindowMap].
  final double? height;

  /// Width of [CustomInfoWindowMap].
  final double width;

  final Function(double top, double left, double width, double height)?
      onChange;

  const CustomInfoWindowMap({
    super.key,
    required this.controller,
    this.onChange,
    this.offset = 50,
    this.height,
    this.width = 100,
  })  : assert(offset >= 0),
        assert(width >= 0);

  @override
  _CustomInfoWindowMapState createState() => _CustomInfoWindowMapState();
}

class _CustomInfoWindowMapState extends State<CustomInfoWindowMap> {
  bool _showNow = false;
  double _leftMargin = 0;
  double _topMargin = 0;
  Widget? _child;
  LatLng? _latLng;

  @override
  void initState() {
    super.initState();
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
    widget.controller.showInfoWindow = _showInfoWindow;
  }

  /// Calculate the position on [CustomInfoWindowMap] and redraw on screen.
  void _updateInfoWindow() async {
    if (_latLng == null ||
        _child == null ||
        widget.controller.googleMapController == null) {
      return;
    }
    ScreenCoordinate screenCoordinate = await widget
        .controller.googleMapController!
        .getScreenCoordinate(_latLng!);
    double devicePixelRatio = 1.0;
    double left =
        (screenCoordinate.x.toDouble() / devicePixelRatio) - (widget.width / 2);
    double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
        (widget.offset * 2.7);
    setState(() {
      _showNow = true;
      _leftMargin = left;
      _topMargin = top;
    });
    widget.onChange?.call(top, left, widget.width, widget.height ?? 0);
  }

  /// Assign the [Widget] and [Marker]'s [LatLng].
  void _addInfoWindow(Widget child, LatLng latLng) {
    _child = child;
    _latLng = latLng;
    _updateInfoWindow();
  }

  /// Notifies camera movements on [GoogleMap].
  void _onCameraMove() {
    if (!_showNow) return;
    _updateInfoWindow();
  }

  /// Disables [CustomInfoWindowMap] visibility.
  void _hideInfoWindow() {
    setState(() {
      _showNow = false;
    });
  }

  /// Enables [CustomInfoWindowMap] visibility.
  void _showInfoWindow() {
    _updateInfoWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _leftMargin,
      top: _topMargin,
      child: Visibility(
        visible: (_showNow == false ||
                (_leftMargin == 0 && _topMargin == 0) ||
                _child == null ||
                _latLng == null)
            ? false
            : true,
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: _child,
        ),
      ),
    );
  }
}
