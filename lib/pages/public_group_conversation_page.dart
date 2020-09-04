import 'dart:async';

import 'package:expanding_button/expanding_button.dart';
import '../pages/public_group_info.dart';
import '../pages/group_conversation_page.dart';
import '../pages/group_info_page.dart';
import '../services/navigation_service.dart';
import 'package:flutter/scheduler.dart';
import '../utils/constants.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

// this shows the group message with the group conversation widget
class PublicGroupConversationPage extends StatefulWidget {
  String _conversationID;
  String _receiverID;
  String _colorName;
  String _receiverImage;
  String _receiverName;
  String _grouprName;
  bool _isPublicGroup;

  PublicGroupConversationPage(this._conversationID, this._receiverID,this._colorName, this._receiverName,
      this._receiverImage,this._grouprName,this._isPublicGroup);

  @override
  State<StatefulWidget> createState() {
    return _PublicGroupConversationPageState();
  }
}

class _PublicGroupConversationPageState extends State<PublicGroupConversationPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  ScrollController _listViewController;
  AuthProvider _auth;

  String _messageText;
  _PublicGroupConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = "";
  }

  bool isPublicGroup = false;
  String colorName="";

  @override
  void initState() {
    setState(() {
      isPublicGroup = widget._isPublicGroup;
    });
    super.initState();
  }
  Future<bool> _willPopCallback() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    timeDilation = 1.0;
    Navigator.pop(context);
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(builder: (_context) {
        return GroupConversationPage(
            widget._conversationID,
            widget._receiverID,
            "",
            widget._receiverName,
            widget._receiverImage,
            widget._grouprName,
            widget._isPublicGroup);
      }),
    );
    // then
    return false; // return true if the route to be popped
  }


  @override
  Widget build(BuildContext context) {

    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: isPublicGroup&&widget._colorName=="Red"?Colors.red
            :isPublicGroup&&widget._colorName=="Purple"?Colors.purple
            :isPublicGroup&&widget._colorName=="Green"?Colors.green
            :isPublicGroup&&widget._colorName=="Yellow"?Colors.yellow
            :Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
          title: Text(this.widget._grouprName),
          actions: <Widget>[
            PopupMenuButton<String>(
              // this is group info popup button to show the group information
              onSelected: (text) async{
                await Future<void>.delayed(const Duration(milliseconds: 100));
                timeDilation = 1.0;
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PublicGroupInfo(this.widget._conversationID)));
              },
              itemBuilder: (BuildContext context){
                return Constants.choices.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _conversationPageUI(),

        ),
      ),
    );


  }



  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return SingleChildScrollView(
      child: Container(
        height: _deviceHeight * 0.75,
        width: _deviceWidth,
        child: StreamBuilder<Conversation>(
          stream: DBService.instance.getConversation(this.widget._conversationID),
          builder: (BuildContext _context, _snapshot) {
            _auth = Provider.of<AuthProvider>(_context);

            var _conversationData = _snapshot.data;
            if (_conversationData != null) {
              if (_conversationData.messages.length != 0) {
                return ListView.builder(
                  controller: _listViewController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: _conversationData.messages.length,
                  itemBuilder: (BuildContext _context, int _index) {

                    var _message = _conversationData.messages[_index];
                    bool _isOwnMessage = _message.senderID == _auth.user.uid;
                    return _messageListViewChild(_isOwnMessage, _message);
                  },
                );
              } else {
                return Align(
                  alignment: Alignment.center,
                  child: Text("Let's start a conversation!"),
                );
              }
            } else {
              return SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _messageListViewChild(bool _isOwnMessage, Message _message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
        _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !_isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          _message.type == MessageType.Text
              ? _textMessageBubble(
              _isOwnMessage, _message.content, _message.timestamp)
              : _imageMessageBubble(
              _isOwnMessage, _message.content, _message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    String a = this.widget._receiverImage;
    String aa = this.widget._receiverImage;
    double _imageRadius = _deviceHeight * 0.05;
    return a==""?Container():Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(this.widget._receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool _isOwnMessage, String _message, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _deviceHeight * 0.08 + (_message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(_message),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool _isOwnMessage, String _imageURL, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    DecorationImage _image =
    DecorationImage(image: NetworkImage(_imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (_input) {
          if (_input.length == 0) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          setState(() {
            _messageText = _input;
          });
        },

        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
          icon: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            timeDilation = 1.0;
            if (_formKey.currentState.validate()) {
              DBService.instance.sendMessage(
                this.widget._conversationID,
                Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    type: MessageType.Text),
              );
              _formKey.currentState.reset();
              FocusScope.of(_context).unfocus();
            }
          }),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}

