


import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'infopage.dart';


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
      AddMarkers(mapController,ConvertCoordinates(doc["lat"], doc["lng"]),doc["title"],doc["story"]
      )));

//mapController.onInfoWindowTapped.add((Marker marker) {});
//  mapController.onMarkerTapped.add((Marker marker){
//
//   print(marker.options.position.longitude);
//    print("Touch marker");
//
//
//
//  });
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
          onPressed: () {

          },
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
    controller.onMarkerTapped.add((Marker marker){
//Marker listener open new page info page
//    print(marker.options.position.longitude);
//    print("Touch marker");
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new AboutPage()));


    });
    return Center(child: mapWidget);
  }
}

LatLng ConvertCoordinates(String lat, String lng){
// Convert strings coordinates to LatLng
  return LatLng(double.parse(lat), double.parse(lng));

}



void AddMarkers(GoogleMapController map, LatLng coor, String title, String story){

  map.addMarker(MarkerOptions(position: coor, infoWindowText:InfoWindowText(title, story)));
}



class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
