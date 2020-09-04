import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Contact {
  final String id;
  final String userId;
  final String email;
  final String image;
  final Timestamp lastseen;
  final String name;
  final String location;
  final GeoPoint geoPosition;
  bool isSelected = false;
  List member;
  final bool isGroup;
  final bool isPublicGroup;

  Contact({this.id,this.userId, this.email, this.name, this.image, this.lastseen, this.location,
    this.geoPosition, this.member, this.isGroup, this.isPublicGroup});
//  Contact({this.id,this.userId, this.email, this.name, this.image, this.lastseen, this.isGroup});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;
    return Contact(
      id: _snapshot.documentID,
      userId: _data["userId"],
      lastseen: _data["lastSeen"],
      email: _data["email"],
      name: _data["name"],
      image: _data["image"],
      member: _data["member"],
      location: _data["location"],
      geoPosition: _data["position"],
      isGroup: _data["isGroup"]==null?false:_data["isGroup"],
      isPublicGroup: _data["isPublicGroup"]==null?false:_data["isPublicGroup"],
    );
  }
}


