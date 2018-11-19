import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() {

  GoogleMapController.init();
  final size = MediaQueryData.fromWindow(ui.window).size;
  final GoogleMapOverlayController controller =
  GoogleMapOverlayController.fromSize(
    width: size.width,
    height: size.height,
  );

  final mapController = controller.mapController;
//  Set firebase https://www.youtube.com/watch?v=DqJ_KjFzL9I
  Firestore.instance
      .collection('Stories')
      .snapshots()
      .listen((data) =>
      data.documents.forEach((doc) =>
//Read all the markers from firebase and add them to map
      AddMarkers(mapController,ConvertCoordinates(doc["lat"], doc["lng"])
      )));

  mapController.addMarker(MarkerOptions(position: LatLng(0 ,0)));
  mapController.onMarkerTapped.add((Marker marker){
                print("Touch marker");
  });
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

LatLng ConvertCoordinates(String lat, String lng){
// Convert strings coordinates to LatLng
  return LatLng(double.parse(lat), double.parse(lng));

}



void AddMarkers(GoogleMapController map, LatLng coor){

  map.addMarker(MarkerOptions(position: coor));
}