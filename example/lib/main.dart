// ignore_for_file: depend_on_referenced_packages

import 'package:clippy_flutter/triangle.dart';
import 'package:custom_info_window_map/custom_info_window_map.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomInfoWindowExample(),
    );
  }
}

class CustomInfoWindowExample extends StatefulWidget {
  const CustomInfoWindowExample({super.key});

  @override
  State<CustomInfoWindowExample> createState() =>
      _CustomInfoWindowExampleState();
}

class _CustomInfoWindowExampleState extends State<CustomInfoWindowExample> {
  final CustomInfoWindowMapController _customInfoWindowController =
      CustomInfoWindowMapController();

  final LatLng _latLng = const LatLng(-7.162305, -34.817195);
  final double _zoom = 15.0;

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    _markers.add(
      Marker(
        markerId: const MarkerId("marker_ci"),
        position: _latLng,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          "Universidade Federal da Paraíba",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black,
                                  ),
                        )
                      ],
                    ),
                  ),
                ),
                Triangle.isosceles(
                  edge: Edge.BOTTOM,
                  child: Container(
                    color: Colors.white,
                    width: 20.0,
                    height: 10.0,
                  ),
                ),
              ],
            ),
            _latLng,
          );
        },
      ),
    );
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) async {
              _customInfoWindowController.googleMapController = controller;
            },
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: _latLng,
              zoom: _zoom,
            ),
          ),
          CustomInfoWindowMap(
            controller: _customInfoWindowController,
            width: 150,
            offset: 50,
          )
        ],
      ),
    );
  }
}
