import '../models/contact.dart';
import 'group_conversation_page.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toast/toast.dart';
import '../services/location_service.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



class GroupSearchPage extends StatefulWidget {
  double _height;
  double _width;

  GroupSearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return _GroupSearchPageState();
  }
}

// Create new groups and search for user
class _GroupSearchPageState extends State<GroupSearchPage> {
  String _searchText;
  String _groupText;
  bool _slowAnimations = true;
  AuthProvider _auth;
  List<Contact> contactList= List<Contact>();
  List<Contact> userList;

  String _generatedGroupLocation;
  GeoPoint _generatedGroupPosition;


  _GroupSearchPageState() {
    _searchText = '';
  }
  @override
  void initState() {
    _setLocation();
    super.initState();
  }

  void _setLocation() async {
    _generatedGroupLocation = await getLocationString();
    _generatedGroupPosition = createGeoPoint(_generatedGroupLocation);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _GroupSearchPageUI(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // Check if the user at least selects one user to create a new group
          if(contactList.length==0){
            // Show toast message if the user doesn't select at least one member
            Toast.show("Please select at least one member", context,gravity: Toast.CENTER);
          }else{
            // Check if the user enters a group name
            if(_groupText==null||_groupText.isEmpty){
              Toast.show("Please enter a group name", context,gravity: Toast.CENTER);
            }else{
              // If the admin selects one users and gives the group name, create method call and create the group and send the user to the conversation widget
              DBService.instance.createOrGetGroupConversation(
                  _auth.user.uid, _groupText, contactList,_generatedGroupLocation,_generatedGroupPosition,
                      (String _conversationID) {
                    // Remove the group search screen from the stack
                        Navigator.of(context).pop();
                        // Navigate the user to the conversation page
                    NavigationService.instance.navigateToRoute(
                      MaterialPageRoute(builder: (_context) {
                        return GroupConversationPage(
                            _conversationID,
                            _conversationID,
                            "",
                            "",
                            "",
                            _groupText,
                          false
                        );
                      }),
                    );
                  },
              );
            }
          }
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _GroupSearchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _groupNameField(),
              _userSearchField(),
              _usersListView(),
            ],
          ),
        );
      },
    );
  }

  Widget _groupNameField() {
    return Container(
      height: this.widget._height * 0.08,
      width: this.widget._width,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(left: 10),
      child: TextField(
        onChanged: ((text){
          setState(() {
            _groupText = text;
          });
        }),
        autocorrect: false,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14
          ),
          labelText: "Enter a group name",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
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

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if (_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
        }
        return _snapshot.hasData
            ? Container(
          height: this.widget._height * 0.60,
          child: ListView.builder(
            itemCount: _usersData.length,
            itemBuilder: (BuildContext _context, int _index) {
              if(userList==null){
                userList = _usersData;
              }
              var _userData = _usersData[_index];
              var _currentTime = DateTime.now();
              var _recipientID = _usersData[_index].id;
              var _isUserActive = !_userData.lastseen.toDate().isBefore(
                _currentTime.subtract(
                  Duration(hours: 1),
                ),
              );
              return ListTile(
                  onTap: () {
                    setState(() {
                      if(userList[_index].isSelected){
                        print(contactList.length);
                        contactList.removeWhere((contact)=>contact.id==_userData.id);
                        print(contactList.length);
                      }else{
                        print(contactList.length);
                        contactList.add(_userData);
                        print(contactList.length);
                      }
                      userList[_index].isSelected = !userList[_index].isSelected;
                    });

                  },
                  title: Text(_userData.name),
                  leading: Container(
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
                  trailing: userList[_index].isSelected?
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: (){
                      setState(() {
                        contactList.removeWhere((contact)=>contact.id==_userData.id);
                        userList[_index].isSelected = false;
                      });
                    },
                  )
                      :IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){
                      setState(() {
                        contactList.add(_userData);
                        userList[_index].isSelected = true;
                      });
                    },
                  )
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

