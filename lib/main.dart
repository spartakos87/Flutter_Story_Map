import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  GoogleMapController.init();
  final size = MediaQueryData.fromWindow(ui.window).size;
  final GoogleMapOverlayController controller =
  GoogleMapOverlayController.fromSize(
    width: size.width,
    height: size.height,
  );
  final mapController = controller.mapController;
  final Widget mapWidget = GoogleMapOverlay(controller: controller);
  runApp(
    MaterialApp(
      home: new Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration.collapsed(hintText: 'Search'),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () async {
                Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//                Get my current position
                final location = LatLng(position.latitude, position.longitude);
                mapController.markers.clear();
                mapController.addMarker(MarkerOptions(
                  position: location,
                ));
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      location, 15.0),
                );
              },
            ),
          ],
        ),
        body: MapsDemo(mapWidget, controller.mapController),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.my_location),
        ),
      ),
      navigatorObservers: <NavigatorObserver>[controller.overlayController],
    ),
  );
}

class MapsDemo extends StatelessWidget {
  MapsDemo(this.mapWidget, this.controller);

  final Widget mapWidget;
  final GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    return Center(child: mapWidget);
  }
}


