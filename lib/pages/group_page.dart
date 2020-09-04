import 'group_search_page.dart';
import 'search_page.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text(
              "New Group",
              style: TextStyle(
                  fontSize: 14
              ),
            ),
            Text(
              "Add Participant",
              style: TextStyle(
                  fontSize: 10
              ),
            ),
          ],
        ),
      ),
      body: GroupSearchPage(MediaQuery.of(context).size.height,MediaQuery.of(context).size.width),
    );
  }
}
