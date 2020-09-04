import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_circle_distance2/great_circle_distance2.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../pages/search_page.dart';
import '../services/location_service.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import 'db_service.dart';

class GMap extends StatefulWidget {
  //GMap({Key key}) : super(key: key); //TODO: THIS MAY HAVE FUCKED EVERYTHING UP BY COMMENTING IT OUT

  List<Contact> locList;

  GMap(List<Contact> lList)
  {
    this.locList = lList;
  }


  @override
  _GMapState createState() => _GMapState(locList);
}


class _GMapState extends State<GMap> {
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  Set<Circle> _theCircles = HashSet<Circle>();
  bool _showMapStyle = false;
  GoogleMapController _mapController;
  BitmapDescriptor _markerIcon;


  List<Contact> locationList;

  _GMapState(List<Contact> locList)
  {
    this.locationList = locList;
  }

  @override
  void initState() {
    super.initState();
    _setMarkerIcon();
    _setPolygons();
    _setPolylines();
  }

  void _setMarkerIcon() async {
    _markerIcon =
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/noodle_icon.png');
  }

  void _toggleMapStyle() async {
    String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');

    if (_showMapStyle) {
      _mapController.setMapStyle(style);
    } else {
      _mapController.setMapStyle(null);
    }
  }


  void _setPolygons() {
    List<LatLng> polygonLatLongs = List<LatLng>();
    polygonLatLongs.add(LatLng(52.364340, 4.900600));
    polygonLatLongs.add(LatLng(52.364340, 4.900600));
    polygonLatLongs.add(LatLng(52.364340, 4.900600));
    polygonLatLongs.add(LatLng(52.364340, 4.900600));

    _polygons.add(
      Polygon(
        polygonId: PolygonId("0"),
        points: polygonLatLongs,
        fillColor: Colors.white,
        strokeWidth: 1,
      ),
    );
  }

  void _setPolylines() {
    List<LatLng> polylineLatLongs = List<LatLng>();
    polylineLatLongs.add(LatLng(52.364340, 4.900600));
    polylineLatLongs.add(LatLng(52.364340, 4.900600));
    polylineLatLongs.add(LatLng(52.364340, 4.900600));
    polylineLatLongs.add(LatLng(52.364340, 4.900600));

    _polylines.add(
      Polyline(
        polylineId: PolylineId("0"),
        points: polylineLatLongs,
        color: Colors.purple,
        width: 1,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    setState(() {
      getJsonFile("assets/mapsMode1.json").then(setMapStyle);
      _markers.add(
        Marker(
            markerId: MarkerId("0"),
            position: LatLng(52.364340, 4.900600),
            infoWindow: InfoWindow(
              title: "Amsterdam centrum",
              snippet: "An Interesting city",
            ),
            icon: _markerIcon),
      );
    });
  }

  Future<String> getJsonFile(String path) async{
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle){
    _mapController.setMapStyle(mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return theMap(context);
  }

  //TODO: VERSION I
  Widget theMap(BuildContext context) {
    _setCircles();
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        height: 190,
        width: 400,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(52.364340, 4.900600),
                zoom: 17,
              ),
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              circles: _theCircles,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ],
        ),
      ),
    );
  }


  void _setCircles() { //TODO: PART OF VERSION II add this as argument:

    /*
    _theCircles.add(
      Circle(
          circleId: CircleId("0"),
          //center: LatLng(double.parse(getLongLat(locList[l].location)[0]),double.parse(getLongLat(locList[l].location)[1])),
          center: LatLng(52.3645, 4.9007),
          radius: 40,
          strokeWidth: 2,
          strokeColor: Colors.lightGreen[100],
          fillColor: Color.fromRGBO(10, 151, 103, .2)),
    );*/


    for(int l = 0; l < locationList.length; l++)
    {
      List<String> theCoords = getLongLat(locationList[l].location);

      //print("User profile #" + l.toString() + "'s lang is:" + theCoords[0]);
      //print("User profile #" + l.toString() + "'s long is:" + theCoords[1]);

      _theCircles.add(
        Circle(
            circleId: CircleId("$l"),
            center: LatLng(double.parse(theCoords[0]),double.parse(theCoords[1])),
            //center: LatLng(52.3645, 4.9007),
            radius: 40,
            strokeWidth: 2,
            strokeColor: Colors.lightGreen[100],
            fillColor: Color.fromRGBO(10, 151, 103, .2)),
      );
    }
  }

  /* TODO: VERSION II

  List<Contact> getFilteredUserList (List<Contact> _fullList, GeoPoint myPoint, double maxDist)
  {
    List<Contact> filteredList = new List<Contact>();
    for(int i = 0; i < _fullList.length; i++)
    {
      var _theirLocation = _fullList[i].geoPosition;
      var _theirDistance = getDistanceBetween(_theirLocation, myPoint);

      if(_theirDistance <= maxDist)
      {
        filteredList.add(_fullList[i]);
      }
    }
    return filteredList;
  }

  double getDistanceBetween(GeoPoint point1, GeoPoint point2, {int method = 2}) {
    var gcd = new GreatCircleDistance.fromDegrees(latitude1: point1.latitude, longitude1: point1.longitude, latitude2: point2.latitude, longitude2: point2.longitude);
    if (method == 1)
      return gcd.haversineDistance();  //miles
    else if (method == 2)
      return gcd.sphericalLawOfCosinesDistance()/1000;  // meters / 1000 = kilometers
    else
      return gcd.vincentyDistance();
  }

  Widget theMap(BuildContext context) {
    return Container(
      child: Builder(builder: (BuildContext _context)
      {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var _userData = _snapshot.data;
            return StreamBuilder<List<Contact>>(
                stream: DBService.instance.getUsersInDB(''),
                builder: (_context, _snapshot) {
                  var _usersData = _snapshot.data;
                  if (_usersData != null) {
                    _usersData.removeWhere((_contact) =>
                    _contact.id == _auth.user.uid);
                  }
                  List<Contact> locList = getFilteredUserList(
                      _usersData, _userData.geoPosition,
                      9000.0); //TODO: this is amount of meters, we should make the distances smaller
                  _setCircles(locList);
                  child:
                  Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      height: 220,
                      width: 400,
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(52.364340, 4.900600),
                              zoom: 17,
                            ),
                            markers: _markers,
                            polygons: _polygons,
                            polylines: _polylines,
                            circles: _theCircles,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          },
        );
      },
      ),
    );
  } */

}


