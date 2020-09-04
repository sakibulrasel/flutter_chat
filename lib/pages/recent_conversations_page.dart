import '../models/conversation.dart';
import '../models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../pages/conversation_page.dart';
import 'group_conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  RecentConversationsPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          GestureDetector(
            // Create a new group button if the user taps -> navigate user to create new group page
            onTap: (){
              NavigationService.instance.navigateTo("group");
            },
            child: Container(
              child: ListTile(
                leading: Icon(
                  Icons.supervised_user_circle,
                  size: 40,
                ),
                title: Text("New Group"),
              ),
            ),
          ),


          // Start Update Data Section
          // Disable this GestureDetector after update data once (done)
//          GestureDetector(
//            // Update All Users Data
//            onTap: (){
//                  DBService.instance.updateUserLocationData().then((value){
//                    print("update done");
//                  });
//            },
//            child: Container(
//              child: ListTile(
//                leading: Icon(
//                  Icons.update,
//                  size: 40,
//                ),
//                title: Text("Update User Data"),
//              ),
//            ),
//          ),

          // End Update Data Section



          Container(
            height: _height*.7,
            width: _width,
            child: ChangeNotifierProvider<AuthProvider>.value(
              value: AuthProvider.instance,
              child: _conversationsListViewWidget(),
            ),
          ),
        ],
      );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: Container(
            height: _height,
            width: _width,
            child: StreamBuilder<List<ConversationSnippet>>(
              stream: DBService.instance.getUserConversations(_auth.user.uid),
              builder: (_context, _snapshot) {
                var _data = _snapshot.data;
                if (_data != null) {
                  _data.removeWhere((_c) {
                    return _c.timestamp == null;
                  });
                  return _data.length != 0
                      ? ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (_context, _index) {
                      return ListTile(
                        onTap: () {
                          // Check if conversation is a group conversation or personal conversation
                          var d = _data[_index].isgroup;
                          var dd = _data[_index].isPublicGroup;
                          if(d) {
                            if (_data[_index].isPublicGroup) {

                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(builder: (_context) {
                                  return GroupConversationPage(
                                      _data[_index].conversationID,
                                      _data[_index].id,
                                      "",
                                      _data[_index].name,
                                      _data[_index].image,
                                      _data[_index].groupname,
                                      _data[_index].isPublicGroup);
                                }),
                              );
                            } else {
                              // If it is a group conversation -> navigate to group conversation page
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(
                                  builder: (BuildContext _context) {
                                    return GroupConversationPage(
                                        _data[_index].conversationID,
                                        _data[_index].id,
                                        "",
                                        _data[_index].name,
                                        _data[_index].image,
                                        _data[_index].groupname,
                                        _data[_index].isPublicGroup);
                                  },
                                ),
                              );
                            }
                          } else {
                            // If it is a personal conversation -> navigate to personal conversation page
                            NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (BuildContext _context) {
                                  return ConversationPage(
                                      _data[_index].conversationID,
                                      _data[_index].id,
                                      _data[_index].name,
                                      _data[_index].image);
                                },
                              ),
                            );
                          }
                        },
                        title: Text(_data[_index].isgroup?_data[_index].groupname:_data[_index].name),
                        subtitle: Text(
                            _data[_index].type == MessageType.Text
                                ? _data[_index].lastMessage
                                : "Attachment: Image"),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_data[_index].image),
                            ),
                          ),
                        ),
                        trailing: _listTileTrailingWidgets(
                            _data[_index].timestamp),
                      );
                    },
                  )
                      : Align(
                    child: Text(
                      "There are no conversations yet",
                      style:
                      TextStyle(color: Colors.white30, fontSize: 15.0),
                    ),
                  );
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
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp _lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "Last Message",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(_lastMessageTimestamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}

