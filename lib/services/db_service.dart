import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/members.dart';

class DBService {
  static DBService instance = DBService();

  Firestore _db;

  DBService() {
    _db = Firestore.instance;
  }

  String _userCollection = "Users";
  String _conversationsCollection = "Conversations";
  String _groupconversationsCollection = "GroupConversations";
  String _callCollection = "Call";
  String _location;

  Future<void> createUserInDB(
      String _uid, String _name, String _imageURL, bool isGroup, String _location, GeoPoint _geoPosition) async {
    try {
      return await _db.collection(_userCollection).document(_uid).setData({
        "userId":_uid,
        "name": _name,
        "email": "",
        "image": _imageURL,
        "isGroup":isGroup,
        "lastSeen": DateTime.now().toUtc(),
         "location": _location,
         "position": _geoPosition,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.updateData({"lastSeen": Timestamp.now()});
  }

  Future<void> updateUserGeopoint(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.updateData({"position": createGeoPoint(_location)});
  }

  Future<void> updateUserLocation(String _userID) async{
    var _ref = _db.collection(_userCollection).document(_userID);
    _location = await getLocationString();
    return _ref.updateData({"location": _location});
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref =
    _db.collection(_conversationsCollection).document(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
      default:
    }
    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _messageType,
          },
        ],
      ),
    });
  }

  Future<void> createOrGetConversation(String _currentID, String _recipientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationsCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .document(_currentID)
        .collection(_conversationsCollection);
    try {
      var conversation =
      await _userConversationRef.document(_recipientID).get();

      if (conversation.data != null) {
        return _onSuccess(conversation.data["conversationID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData(
          {
            "members": [_currentID, _recipientID],
            "ownerID": _currentID,
            'messages': [],
            "groupname": "",
            "admin":[],
            "adminname":"",
            "createdat":Timestamp.now(),
            "member":[],
            'group':false,
          },
        );
        return _onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getUsername() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser currentuser = await auth.currentUser();
    var _userConversationRef = _db
        .collection(_userCollection);
    var user =
    await _userConversationRef.document(currentuser.uid).get();

   if(user.data!=null){
     return  user.data["name"];
   }else{
     return null;
   }
  }


  Future<void> createOrGetGroupConversation(String _currentID, String _groupName, List<Contact> _recipient,String _generatedGroupLocation,GeoPoint _generatedGroupPosition,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationsCollection);
    var _userRef = _db.collection(_userCollection);
    var _userConversationRef = _db
        .collection(_userCollection);
    var user =
    await _userConversationRef.document(_currentID).get();

    String adminName = user.data["name"];
    String userId = user.data["userId"];
    Members m = Members(memberid: _currentID, membername: adminName, role: "Admin");

    List<Members> _allmemberList = List<Members>();
    _allmemberList.add(m);
    Members ms;
    List<String> _recipientIdList=List<String>();
    _recipientIdList.add(_currentID);
    _recipient.forEach((contact){
      _recipientIdList.add(contact.id);
      ms = new Members(memberid: contact.id,membername: contact.name,role: "Member");
      _allmemberList.add(ms);
    });



    try {
      var _conversationRef = _ref.document();

      await _conversationRef.setData(
        {
          "members": _recipientIdList,
          "groupname": _groupName,
          "adminname": adminName,
          "admin":[{
            "adminid":_currentID,
            "adminname":adminName
          }],
          "member":_allmemberList.map((item){
            return item.toJson();
          }).toList(),
          "createdat":Timestamp.now(),
          "ownerID": _currentID,
          'messages': [{
            "timestamp": Timestamp.now(),
            "type":"text",
            "senderId":_currentID,
            "message":"Group Created"
          }],
          'group':true,
          'location': _generatedGroupLocation,
          'position': _generatedGroupPosition,
          'isPublicGroup':false
        },
      );
      // Create a user as a group
      var _uRef = _userRef.document(_conversationRef.documentID);
      await _uRef.setData({
        "userId": _conversationRef.documentID,
        "name": _groupName,
        "member": _recipientIdList,
        "email": "",
        "image": "",
        "isGroup": true,
        "lastSeen": DateTime.now().toUtc(),
        "location": _generatedGroupLocation,
        "position": _generatedGroupPosition,
      });
      return _onSuccess(_conversationRef.documentID);
    } catch (e) {
      print(e);
    }
  }


  Future<bool> joinPublicGroup(Contact c, String userId) async{
    var _ref = _db.collection(_conversationsCollection);
    var _userRef = _db.collection(_userCollection);
    var user =
        await _userRef.document(userId).get();

    await _userRef.document(c.id).updateData({
      "member":FieldValue.arrayUnion([user.documentID])
          });
      await _ref.document(c.id).updateData({
        "member":FieldValue.arrayUnion([
          {
            "memberid": userId,
            "membername": user.data["name"],
            "role": "Member"
          }
        ]),
        "members":FieldValue.arrayUnion([userId])
      });

      await _userRef.document(userId).collection(_conversationsCollection).document(c.id).setData({
        "conversationID": c.id,
        "image": user.data["image"],
        "name": user.data["name"],
        "group":true,
        "isPublicGroup":true,
        "groupname":c.name,
        "timestamp":Timestamp.now(),
        "unseenCount": 0,
      });
      return true;
  }








  // delete user from the group
  Future<bool> removeUser(String conversationId, String userid, Members members) async{
    var val=[userid];
    var mval=[members.toJson()];
    var mvalue=[members.memberid];
    var _ref = _db.collection(_conversationsCollection);
    var _uref = _db.collection(_userCollection);
    var _conversationRef =  _ref.document(conversationId);
    var _userRef =  _uref.document(conversationId);
    await _userRef.updateData({
      "member":FieldValue.arrayRemove(mvalue),
      });

    await _conversationRef.updateData({
      "member":FieldValue.arrayRemove(mval),
      "members":FieldValue.arrayRemove(val),

    });
    await _db
        .collection(_userCollection).document(userid).collection(_conversationsCollection).document(conversationId).delete();
    return true;
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_conversationsCollection);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Future<List<ConversationSnippet>> getUserGroupConversations() async {

    List<ConversationSnippet> conversationList=List<ConversationSnippet>();
    FirebaseAuth _auth= FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    QuerySnapshot _groupref = await _db
        .collection(_userCollection)
        .document(user.uid)
        .collection(_groupconversationsCollection).getDocuments();

    conversationList.addAll(
        _groupref.documents.map((doc)=>ConversationSnippet(
          id: doc.documentID,
          conversationID: doc.data["conversationID"],
          lastMessage: doc.data["lastMessage"] != null ? doc.data["lastMessage"] : "",
          unseenCount: doc.data["unseenCount"],
          timestamp: doc.data["timestamp"] != null ? doc.data["timestamp"] : null,
          name: doc.data["name"],
          image: doc.data["image"],
          type: doc.data["type"]==null?MessageType.Text:doc.data["type"]=="text"?MessageType.Text:MessageType.Image,
        )).toList()
    );

    QuerySnapshot _ref = await _db
        .collection(_userCollection)
        .document(user.uid)
        .collection(_conversationsCollection).getDocuments();

    conversationList.addAll(
        _ref.documents.map((doc)=>ConversationSnippet(
          id: doc.documentID,
          conversationID: doc.data["conversationID"],
          lastMessage: doc.data["lastMessage"] != null ? doc.data["lastMessage"] : "",
          unseenCount: doc.data["unseenCount"],
          timestamp: doc.data["timestamp"] != null ? doc.data["timestamp"] : null,
          name: doc.data["name"],
          image: doc.data["image"],
          type: doc.data["type"]==null?MessageType.Text:doc.data["type"]=="text"?MessageType.Text:MessageType.Image,
        )).toList()
    );
    return conversationList;

  }


  Future<bool> updateUserLocationData() async{
    List<Contact> contactList = List<Contact>();
    QuerySnapshot _userref = await _db
        .collection(_userCollection)
        .getDocuments();

    contactList.addAll(
        _userref.documents.map((doc)=>Contact(
          id: doc.documentID,
          userId: doc.data["userId"],
          lastseen: doc.data["lastSeen"],
          email: doc.data["email"],
          name: doc.data["name"],
          image: doc.data["image"],
          isGroup: doc.data["isGroup"]==null?false:doc.data["isGroup"],
        )).toList()
    );
    _location = await getLocationString();

    contactList.forEach((user) async {
      var _ref =  await _db.collection(_userCollection).document(user.id).updateData({
        "position": createGeoPoint(_location),
        "location": _location
      });
    });
    return true;

  }

  // To update previous user data, function only needed once (done)
  Future<bool> updateUserData() async{
    List<Contact> contactList = List<Contact>();
    QuerySnapshot _userref = await _db
        .collection(_userCollection)
        .getDocuments();

    contactList.addAll(
        _userref.documents.map((doc)=>Contact(
          id: doc.documentID,
          userId: doc.data["userId"],
          lastseen: doc.data["lastSeen"],
          email: doc.data["email"],
          name: doc.data["name"],
          image: doc.data["image"],
          isGroup: doc.data["isGroup"]==null?false:doc.data["isGroup"],
        )).toList()
    );

    contactList.forEach((user) async {
      var _ref =  await _db.collection(_userCollection).document(user.id).updateData({
        "member":[user.id]
      });
    });
    return true;

  }

// Get users without group
  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _db
        .collection(_userCollection)
        .where("isGroup", isEqualTo: false)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');
    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  // Get users and groups
  Stream<List<Contact>> getUsersAndGroupInDB(String _searchName, String _uid) {
    var _ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');

    return _ref.getDocuments().asStream().map((_snapshot) {

      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();

      });
  }

  Stream<Conversation> getConversation(String _conversationID) {
    var _ref =
      _db.collection(_conversationsCollection).document(_conversationID);
    return _ref.snapshots().map(
          (_doc) {
        return Conversation.fromFirestore(_doc);
      },
    );
  }
}

