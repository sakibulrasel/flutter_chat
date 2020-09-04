import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../models/members.dart';
import '../services/db_service.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';


class GroupInfo extends StatefulWidget {
  String _conversationID;

  GroupInfo(this._conversationID);
  @override
  _GroupInfoState createState() => _GroupInfoState();
}

// group information page
class _GroupInfoState extends State<GroupInfo> {

  double _deviceHeight;
  double _deviceWidth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text("Group Info"),
      ),
      body: SingleChildScrollView(
        child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Container(
          height: _deviceHeight * 0.75,
          width: _deviceWidth,
          child: StreamBuilder<Conversation>(
            // retrieve the group information from the database
            stream: DBService.instance.getConversation(this.widget._conversationID),
            builder: (BuildContext _context, _snapshot) {
              var _auth = Provider.of<AuthProvider>(_context);
              var _conversationData = _snapshot.data;
              if (_conversationData != null) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 200,
                            color: Colors.grey,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20,top: 100),
                            child: Text(
                              // Group name
                                _conversationData.groupname,
                              style: TextStyle(
                                fontSize: 25
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20,top: 150),
                            child: Text(
                              // Group admin name and time created
                              "Created By "+_conversationData.adminname +" "+_conversationData.createdat.toDate().year.toString()+" - "+_conversationData.createdat.toDate().month.toString()+" - "+_conversationData.createdat.toDate().day.toString() + "  "+_conversationData.createdat.toDate().hour.toString()+" : "+_conversationData.createdat.toDate().minute.toString(),
                              style: TextStyle(
                                fontSize: 14
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        itemCount: _conversationData.member.length,
                        itemBuilder: (BuildContext _context, int _index) {
                          return Card(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(_conversationData.member[_index].membername),
                                      ),
                                      // Check if the user is a admin or not, if the user is a admin the delete buttons are shown
                                      _auth.user.uid==_conversationData.ownerID?Container(
                                        child: IconButton(
                                          icon: Icon(Icons.delete,color: Colors.red,),
                                          onPressed: (){
                                            //  If the selected user is not the admin show the alert dialogue and delete the user
                                            if(_conversationData.member[_index].role=="Member"){
                                              showDialog(context: context,builder: (context){
                                                return AlertDialog(
                                                  title: Text("Remove User"),
                                                  content: Text("Are you sure to remove the user?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("No"),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Yes"),
                                                      onPressed: (){
                                                        String memberid= _conversationData.member[_index].memberid;
                                                        String membername= _conversationData.member[_index].membername;
                                                        String role= _conversationData.member[_index].role;

                                                        Members m = Members(memberid: memberid,membername: membername,role: role);
                                                        // Delete the user of the group
                                                        DBService.instance.removeUser(_conversationData.id, _conversationData.member[_index].memberid, m).then((value){
                                                          if(value){
                                                            // Close the alert dialogue
                                                            Navigator.of(context).pop();
                                                          }
                                                        });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                            }
                                          },
                                        ),
                                      ):Container()
                                    ],
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                ),
                              Container(

                                child: Text(
                                _conversationData.member[_index].role,
                                style: TextStyle(
                                  fontSize: 12
                                ),
                                ),
                              )

                            ],
                          ),
                        ),
                      );
                          },
                    ),
                  )
                ],
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
      ),
      ),
    );
  }
}
