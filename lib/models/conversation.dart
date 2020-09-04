import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin.dart';
import '../models/members.dart';

import 'message.dart';

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final String groupname;
  final MessageType type;
  final int unseenCount;
  final Timestamp timestamp;
  final bool isgroup;
  final bool isPublicGroup;



  ConversationSnippet(
      {this.conversationID,
        this.id,
        this.lastMessage,
        this.unseenCount,
        this.timestamp,
        this.name,
        this.image,
        this.groupname,
        this.type,
        this.isgroup,
        this.isPublicGroup});

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;
    var _messageType = MessageType.Text;
    if (_data["type"] != null) {
      switch (_data["type"]) {
        case "text":
          break;
        case "image":
          _messageType = MessageType.Image;
          break;
        default:
      }
    }
    return ConversationSnippet(
      id: _snapshot.documentID,
      conversationID: _data["conversationID"],
      lastMessage: _data["lastMessage"] != null ? _data["lastMessage"] : "",
      unseenCount: _data["unseenCount"],
      isgroup: _data["group"],
      isPublicGroup: _data["isPublicGroup"]==null?false:_data["isPublicGroup"],
      timestamp: _data["timestamp"] != null ? _data["timestamp"] : null,
      name: _data["name"],
      groupname: _data["groupname"] !=null?_data["groupname"]:null,
      image: _data["image"],
      type: _messageType,

    );
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final List<Members> member;
  final String ownerID;
  final String groupInfo;
  final bool group;
  final String groupname;
  final String adminname;
  final Timestamp createdat;

  Conversation({this.id, this.members,this.member, this.ownerID, this.messages,this.group,this.groupname,this.adminname,this.createdat,this.groupInfo});

  factory Conversation.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;
    List _member = _data["member"];
    List _messages = _data["messages"];


    if(_member!=null){
      _member = _member.map((_a){
        return Members(
          memberid: _a["memberid"],
          membername: _a["membername"],
          role: _a["role"],

        );
      }).toList();
    }else{
      _member=[];
    }
    if (_messages != null) {
      _messages = _messages.map(
            (_m) {
          return Message(
              type: _m["type"] == "text" ? MessageType.Text : MessageType.Image,
              content: _m["message"],
              timestamp: _m["timestamp"],
              senderID: _m["senderID"]);
        },
      ).toList();
    } else {
      _messages = [];
    }
    return Conversation(
        id: _snapshot.documentID,
        members: _data["members"],
        member: _member,
        ownerID: _data["ownerID"],
        group: _data["group"],
        groupname: _data["groupname"],
        adminname: _data["adminname"]!=null?_data["adminname"]:"",
        groupInfo: _data["groupInfo"]!=null?_data["groupInfo"]:"",
        messages: _messages,
        createdat:_data["createdat"]
    );
  }
}
