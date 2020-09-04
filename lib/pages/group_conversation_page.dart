import 'dart:async';

import 'package:expanding_button/expanding_button.dart';
import '../pages/group_info_page.dart';
import '../pages/public_group_conversation_page.dart';
import '../pages/public_group_info.dart';
import '../services/navigation_service.dart';

import '../utils/constants.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

// this shows the group message with the group conversation widget
class GroupConversationPage extends StatefulWidget {
  String _conversationID;
  String _receiverID;
  String _colorName;
  String _receiverImage;
  String _receiverName;
  String _grouprName;
  bool _isPublicGroup;

  GroupConversationPage(this._conversationID, this._receiverID,this._colorName, this._receiverName,
      this._receiverImage,this._grouprName,this._isPublicGroup);

  @override
  State<StatefulWidget> createState() {
    return _GroupConversationPageState();
  }
}

class _GroupConversationPageState extends State<GroupConversationPage> {
  double _deviceHeight;
  double _deviceWidth;
  bool _slowAnimations = true;

  GlobalKey<FormState> _formKey;
  ScrollController _listViewController;
  AuthProvider _auth;

  String _messageText;
  _GroupConversationPageState() {
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




  @override
  Widget build(BuildContext context) {

    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(this.widget._grouprName),
        actions: <Widget>[
          PopupMenuButton<String>(
            // this is group info popup button to show the group information
            onSelected: (text) async{
              await Future<void>.delayed(const Duration(milliseconds: 100));
              timeDilation = 1.0;
              if(isPublicGroup){
               
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PublicGroupInfo(this.widget._conversationID)));
              }else{
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupInfo(this.widget._conversationID)));
              }
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
        child:isPublicGroup?SingleChildScrollView(
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Column(
                children: <Widget>[

                  Container(
//              color: Colors.wh,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[

//                            ExpandingButton(
//                              tag: "Text 1",
//                              // child <Widget>
//                              child: Text('Text 1', style: TextStyle(color: Colors.black)),
//                              // onTap <VoidCallback>
//                              onTap: () {
//                                setState(() {
//                                  colorName="Red";
//                                });
//                              },
//                              // onTapWhenExpanded <VoidCallback>
//                              onTapWhenExpanded: () {print('collapse');},
//                              // background <Color>
//                              background: Colors.red,
//                              // backgroundAfterAnimation <Color>
//                              backgroundAfterAnimation: Colors.red,
//                            ),
                              GestureDetector(
                                onTap: () async{
                                  await Future<void>.delayed(const Duration(milliseconds: 100));
                                  timeDilation = _slowAnimations ? 5.0 : 1.0;
                                  Navigator.pop(context);
                                  NavigationService.instance.navigateToRoute(
                                    MaterialPageRoute(builder: (_context) {
                                      return PublicGroupConversationPage(
                                          widget._conversationID,
                                          widget._receiverID,
                                          "Red",
                                          widget._receiverImage,
                                          widget._receiverName,
                                          widget._grouprName,
                                          widget._isPublicGroup);
                                    }),
                                  );

                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius:  BorderRadius.circular(10.0),
                                    color: Colors.redAccent,
                                  ),

                                  height: 80,
                                  width: MediaQuery.of(context).size.width/2.5,
                                  child: Center(

                                    child: Text(
                                      "Text 1",
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
//                                      child:  ExpandingButton(
//                                        tag: "Text 1",
//                                        // child <Widget>
//                                        child: Text('Text 1', style: TextStyle(color: Colors.black)),
//                                        // onTap <VoidCallback>
//                                        onTap: () {
//                                          Future.delayed(const Duration(milliseconds: 1), () {
//                                            setState(() {
//                                              // Here you can write your code for open new view
//                                              Navigator.pop(context);
//                                              Navigator.pop(context);
//                                              NavigationService.instance.navigateToRoute(
//                                                MaterialPageRoute(builder: (_context) {
//                                                  return PublicGroupConversationPage(
//                                                      widget._conversationID,
//                                                      widget._receiverID,
//                                                      "Red",
//                                                      widget._receiverImage,
//                                                      widget._receiverName,
//                                                      widget._grouprName,
//                                                      widget._isPublicGroup);
//                                                }),
//                                              );
//                                            });
//                                          });
//                                        },
//                                        // onTapWhenExpanded <VoidCallback>
//                                        onTapWhenExpanded: () {
//                                          setState(() {
//                                            colorName="Red";
//                                          });
//                                        },
//                                        // background <Color>
//                                        background: Colors.redAccent,
//                                        // backgroundAfterAnimation <Color>
//                                        backgroundAfterAnimation: Colors.redAccent,
//                                      ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () async{
                                  await Future<void>.delayed(const Duration(milliseconds: 100));
                                  timeDilation = _slowAnimations ? 5.0 : 1.0;
                                  Navigator.pop(context);
                                  NavigationService.instance.navigateToRoute(
                                    MaterialPageRoute(builder: (_context) {
                                      return PublicGroupConversationPage(
                                          widget._conversationID,
                                          widget._receiverID,
                                          "Purple",
                                          widget._receiverImage,
                                          widget._receiverName,
                                          widget._grouprName,
                                          widget._isPublicGroup);
                                    }),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius:  BorderRadius.circular(10.0),
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  height: 80,
                                  width: MediaQuery.of(context).size.width/2.5,
                                  child: Center(
                                    child: Text(
                                      "Text 2",
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
//                                      child: ExpandingButton(
//                                        tag: "Text 2",
//                                        // child <Widget>
//                                        child: Text('Text 2', style: TextStyle(color: Colors.black)),
//                                        // onTap <VoidCallback>
//                                        onTap: ()  {
//
//                                          Future.delayed(const Duration(milliseconds: 1), () {
//                                            setState(() {
//                                              // Here you can write your code for open new view
//                                              Navigator.pop(context);
//                                              Navigator.pop(context);
//                                              NavigationService.instance.navigateToRoute(
//                                                MaterialPageRoute(builder: (_context) {
//                                                  return PublicGroupConversationPage(
//                                                      widget._conversationID,
//                                                      widget._receiverID,
//                                                      "Purple",
//                                                      widget._receiverImage,
//                                                      widget._receiverName,
//                                                      widget._grouprName,
//                                                      widget._isPublicGroup);
//                                                }),
//                                              );
//                                            });
//                                          });
//
//                                        },
//                                        // onTapWhenExpanded <VoidCallback>
//                                        onTapWhenExpanded: () {
//
//                                        },
//                                        // background <Color>
//                                        background: Colors.deepPurpleAccent,
//                                        // backgroundAfterAnimation <Color>
//                                        backgroundAfterAnimation: Colors.deepPurpleAccent,
//                                      ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async{
                                  await Future<void>.delayed(const Duration(milliseconds: 100));
                                  timeDilation = _slowAnimations ? 5.0 : 1.0;
                                  Navigator.pop(context);
                                  NavigationService.instance.navigateToRoute(
                                    MaterialPageRoute(builder: (_context) {
                                      return PublicGroupConversationPage(
                                          widget._conversationID,
                                          widget._receiverID,
                                          "Green",
                                          widget._receiverImage,
                                          widget._receiverName,
                                          widget._grouprName,
                                          widget._isPublicGroup);
                                    }),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:  BorderRadius.circular(10.0),
                                    color: Colors.greenAccent,
                                  ),
                                  height: 80,
                                  width: MediaQuery.of(context).size.height/5,
                                  child: Center(
                                    child: Text(
                                      "Text 3",
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
//                                      child: ExpandingButton(
//                                        tag: "Text 3",
//                                        // child <Widget>
//                                        child: Text('Text 3', style: TextStyle(color: Colors.black)),
//                                        // onTap <VoidCallback>
//                                        onTap: () {
//                                          Future.delayed(const Duration(milliseconds: 1), () {
//                                            setState(() {
//                                              // Here you can write your code for open new view
//                                              Navigator.pop(context);
//                                              Navigator.pop(context);
//                                              NavigationService.instance.navigateToRoute(
//                                                MaterialPageRoute(builder: (_context) {
//                                                  return PublicGroupConversationPage(
//                                                      widget._conversationID,
//                                                      widget._receiverID,
//                                                      "Green",
//                                                      widget._receiverImage,
//                                                      widget._receiverName,
//                                                      widget._grouprName,
//                                                      widget._isPublicGroup);
//                                                }),
//                                              );
//                                            });
//                                          });
//                                        },
//                                        // onTapWhenExpanded <VoidCallback>
//                                        onTapWhenExpanded: () {
//                                          setState(() {
//                                            colorName="Green";
//                                          });
//                                        },
//                                        // background <Color>
//                                        background: Colors.greenAccent,
//                                        // backgroundAfterAnimation <Color>
//                                        backgroundAfterAnimation: Colors.greenAccent,
//                                      ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () async{
                                  await Future<void>.delayed(const Duration(milliseconds: 100));
                                  timeDilation = _slowAnimations ? 5.0 : 1.0;
                                  Navigator.pop(context);
                                  NavigationService.instance.navigateToRoute(
                                    MaterialPageRoute(builder: (_context) {
                                      return PublicGroupConversationPage(
                                          widget._conversationID,
                                          widget._receiverID,
                                          "Yellow",
                                          widget._receiverImage,
                                          widget._receiverName,
                                          widget._grouprName,
                                          widget._isPublicGroup);
                                    }),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:  BorderRadius.circular(10.0),
                                    color: Colors.yellowAccent,
                                  ),
                                  height: 80,
                                  width: MediaQuery.of(context).size.height/5,
                                  child: Center(
                                    child: Text(
                                      "Text 4",
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
//                                      child: ExpandingButton(
//                                        tag: "Text 4",
//                                        // child <Widget>
//                                        child: Text('Text 4', style: TextStyle(color: Colors.black)),
//                                        // onTap <VoidCallback>
//                                        onTap: () {
//                                          Future.delayed(const Duration(milliseconds: 1), () {
//                                            setState(() {
//                                              // Here you can write your code for open new view
//                                              Navigator.pop(context);
//                                              Navigator.pop(context);
//                                              NavigationService.instance.navigateToRoute(
//                                                MaterialPageRoute(builder: (_context) {
//                                                  return PublicGroupConversationPage(
//                                                      widget._conversationID,
//                                                      widget._receiverID,
//                                                      "Yellow",
//                                                      widget._receiverImage,
//                                                      widget._receiverName,
//                                                      widget._grouprName,
//                                                      widget._isPublicGroup);
//                                                }),
//                                              );
//                                            });
//                                          });
//
//
//                                        },
//                                        // onTapWhenExpanded <VoidCallback>
//                                        onTapWhenExpanded: () {
//
//                                        },
//                                        // background <Color>
//                                        background: Colors.yellowAccent,
//                                        // backgroundAfterAnimation <Color>
//                                        backgroundAfterAnimation: Colors.yellowAccent,
//
//                                      ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        _messageListView(),
                        _messageField(context)


                      ],
                    ),
                  ),

                ],
              ),

//              Align(
//                alignment: Alignment.bottomCenter,
//                child: _messageField(context),
//              ),
            ],
          ),
        ):_conversationPageUI(),

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
        height: this.widget._isPublicGroup?_deviceHeight * 0.53:_deviceHeight * 0.75,
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
          onPressed: () {
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
