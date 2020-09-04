import '../pages/group_conversation_page.dart';

import '../models/contact.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../pages/conversation_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:great_circle_distance2/great_circle_distance2.dart';
import 'dart:async';
import '../services/map_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

List<Contact> filteredList;

class SearchPage extends StatefulWidget {
  double _height;
  double _width;

  SearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _searchText;

  AuthProvider _auth;

  _SearchPageState(){
    _searchText = '';
  }

  void _locationRefresh(String uid) async
  {
    await DBService.instance.updateUserLocation(uid);
    await DBService.instance.updateUserGeopoint(uid);
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


  @override
  Widget build(BuildContext _context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
        ),
    );
  }


//  Widget _searchPageUI() {
//    //the entire search page widget
//    return Builder(
//      builder: (BuildContext _context) {
//        _auth = Provider.of<AuthProvider>(_context);
//        return Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          mainAxisSize: MainAxisSize.max,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            _userSearchField(),
//            _usersListView(),
////            _usersListView(),
//          ],
//        );
//      },
//    );
//  }

  Widget _searchPageUI() { //the entire search page widget
    return Container(
      height: 550,
      child: Builder(builder: (BuildContext _context)
      {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var _userData = _snapshot.data;
            return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _userSearchField(),
                    _userData!=null?_usersListView(_userData.geoPosition, _userData.id):Container()
                  ],
                )
            );
          },
        );
      },
      ),
    );
  }







  Widget _userSearchField() {
    return Container(
      height: this.widget._height * 0.08,
      width: this.widget._width,
      padding: EdgeInsets.symmetric(vertical: this.widget._height * 0.02),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }


  Widget _usersListView(GeoPoint loc, String uid) {
//  Widget _usersListView() {

    //GeoPoint loc = GeoPoint(52.3645233, 4.90054);
    //String uid = "0UMct3ORPUcfe4XBcdKVpSRRRL63";

    GeoPoint ourLoc = loc;

    const oneSec = const Duration(seconds:10); //This is to update the user's location every x seconds (in this case 10s), 10s may be too much
    new Timer.periodic(oneSec, (Timer t) => _locationRefresh(uid));

    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersAndGroupInDB(_searchText,_auth.user.uid),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if(_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
          var toRemove = [];
          _usersData.forEach((user) {
            if (user.isGroup && !user.isPublicGroup) {
              bool isFound = false;
              for (int i = 0; i < user.member.length; i++) {
                if (user.member[i] == _auth.user.uid) {
                  isFound = true;
                  break;
                } else {
                  isFound = false;
                }
              }
              if (!isFound) {
                toRemove.add(user);
              }
            }
          });

          _usersData.removeWhere((c) => toRemove.contains(c));

           filteredList = getFilteredUserList(_usersData, ourLoc,
               9000.0); //TODO: this is amount of meters, we should make the distances smaller

        }
        return _snapshot.hasData
            ? Container(
              height: this.widget._height * 0.60,
              child: ListView.builder(
                itemCount: filteredList.length,
//                itemCount: _usersData.length,
                itemBuilder: (BuildContext _context, int _index) {
                var _userData = filteredList[_index];
//                  var _userData = _usersData[_index];
                  var _currentTime = DateTime.now();
                  var _recipientID = filteredList[_index].id;
//                  var _recepientID = _usersData[_index].id;
                  var _isUserActive = !_userData.lastseen.toDate().isBefore(
                    _currentTime.subtract(
                      Duration(hours: 1),
                    ),
                  );
                  var _theirLocation = _userData.geoPosition;
                  var _theirDistance = getDistanceBetween(_theirLocation, ourLoc).toStringAsFixed(1);

                  return ListTile(
                    onTap: () {
                      if (_userData.isGroup) {
                        if (_userData.isPublicGroup){
                          if(_userData.member.contains(_auth.user.uid)){
                        NavigationService.instance.navigateToRoute(
                          MaterialPageRoute(builder: (_context) {
                            return GroupConversationPage(
                              _userData.userId,
                              _userData.userId,
                              "",
                              "",
                              "",
                              _userData.name,
                              true);
                          }),
                        );
                      } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext c) {
                                return AlertDialog(
                                  title: Text("Join this Public Chat"),
                                  content: Text("Would you like to join this public chat?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("No"),
                                      onPressed: () {
                                        Navigator.pop(c);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("Yes"),
                                      onPressed: () {
                                        DBService.instance.joinPublicGroup(_userData,_auth.user.uid).then((value) {
                                          if(value){
                                            Navigator.pop(c);
                                            NavigationService.instance.navigateToRoute(
                                              MaterialPageRoute(builder: (_context) {
                                                return GroupConversationPage(
                                                  _userData.userId,
                                                  _userData.userId,
                                                  "",
                                                  "",
                                                  "",
                                                  _userData.name,
                                                  true);
                                              }),
                                            );
                                          }
                                        });
                                      },
                                    )
                                  ],
                                );
                              }
                            );
                          }
                        } else {
                          NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(builder: (_context) {
                              return GroupConversationPage(
                                  _userData.userId,
                                  _userData.userId,
                                  "",
                                  "",
                                  "",
                                  _userData.name,
                                  false);
                            }),
                          );
                        }
                        } else {
                        DBService.instance.createOrGetConversation(
                            _auth.user.uid, _recipientID,
                                (String _conversationID) {
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(builder: (_context) {
                                  return ConversationPage(
                                      _conversationID,
                                      _recipientID,
                                      _userData.name,
                                      _userData.image);
                                }),
                              );
                            });
                      }
                    },
                    title: Text(_userData.name),
                    leading: _userData.isGroup?
                    Container(
                      width: 50,
                      height: 50,
                    )
                    :Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_userData.image),
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "$_theirDistance km away",
                          style: TextStyle(fontSize: 11),
                        ),
                        _isUserActive
                            ? Text(
                          "Active Now",
                          style: TextStyle(fontSize: 11),
                        )
                            : Text(
                          "Last Seen:",
                          style: TextStyle(fontSize: 11),
                        ),
                        _isUserActive
                            ? Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        )
                            : Text(
                          timeago.format(
                            _userData.lastseen.toDate(),
                          ),
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
        )
            : SpinKitWanderingCubes(
          color: Colors.blue,
          size: 50.0,
        );
      },
    );
  }
}

