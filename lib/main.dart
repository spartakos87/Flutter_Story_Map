import 'dart:ui' as ui;
import  'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
//  TODO check if every time I come back the above commands call
  Firestore.instance.collection('Stories').snapshots().listen((data) =>
      data.documents.forEach((doc) =>
//Read all the markers from firebase and add them to map

          AddMarkers(mapController, ConvertCoordinates(doc["lat"], doc["lng"]),
              doc["title"], doc["story"], doc["url"])));



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
                Position position = await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//                Get my current position
                final location = LatLng(position.latitude, position.longitude);
                mapController.markers.clear();
                mapController.addMarker(MarkerOptions(
                    position: location,
                    infoWindowText: InfoWindowText("Here you are!", "Add me"),
                    visible: true));
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(location, 20.0),
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

    controller.onMarkerTapped.add((Marker marker) async {
//Marker listener open new page info page

      String titlos = marker.options.infoWindowText.title;
      String story = marker.options.infoWindowText.snippet.split("?")[0];
      String url = marker.options.infoWindowText.snippet.split("?")[1];


      String realUrl = await makeRequest(url);
      String downloadUrl =getDownloadUrl(realUrl,url);

      if (titlos != "Here you are!") {
        Navigator.push(
//        Parse title to next page/screen

            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new AboutPage(title: titlos, story: story, url: downloadUrl,)));
      } else {
        Navigator.push(
//        Parse title to next page/screen
            context,
            new MaterialPageRoute(builder: (context) => new SecondScreen()));
      }
    });
    return Center(child: mapWidget);
  }
}

LatLng ConvertCoordinates(String lat, String lng) {
// Convert strings coordinates to LatLng
  return LatLng(double.parse(lat), double.parse(lng));
}

void AddMarkers(GoogleMapController map, LatLng coor, String title,
    String story, String url) {
  map.addMarker(MarkerOptions(
      position: coor, infoWindowText: InfoWindowText(title, '$story'+'?'+'$url')));
}


Future<String> makeRequest(String n) async {
  String baseUrl = 'https://firebasestorage.googleapis.com/v0/b/storymap-da000.appspot.com/o/';
  String url = '$baseUrl' + '$n';
  var client = new http.Client();
  final response = await client.get(url);


return response.body;
}


String getDownloadUrl(String url, String name){
  String baseUrl = 'https://firebasestorage.googleapis.com/v0/b/storymap-da000.appspot.com/o/';
  String token =  url.replaceAll("{", "").replaceAll("}", "").split('"downloadTokens": ')[1].replaceAll('"', '');
  return '$baseUrl'+'$name'+"?alt=media&token="+'$token';

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
