import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/feedback.dart';
import '../services/db_service.dart';
import '../services/feedback_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';

class PublicGroupInfo extends StatefulWidget {
  String _conversationID;
  PublicGroupInfo(this._conversationID);
  @override
  _PublicGroupInfoState createState() => _PublicGroupInfoState();
}

class _PublicGroupInfoState extends State<PublicGroupInfo> {
  TextEditingController feedbackController= TextEditingController();
  TextEditingController nameController= TextEditingController();
  String name;

  @override
  void initState() {
    DBService.instance.getUsername().then((value){
      setState(() {
        name = value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget._conversationID),
        builder: (BuildContext _context, _snapshot){
          var conversationData = _snapshot.data;
          if(conversationData!=null){
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(conversationData.groupInfo),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Total Member : " +conversationData.members.length.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 80),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding:EdgeInsets.all(10),
                          child: TextField(
                            controller: nameController,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: "Name",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding:EdgeInsets.all(10),
                          child: TextField(
                            maxLines: 4,
                            controller: feedbackController,
                            autocorrect: false,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: "Feedback",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding:EdgeInsets.all(50),
                          child: RaisedButton(
                            onPressed: (){
                              if(nameController.text.isEmpty|| feedbackController.text.isEmpty){
                                Toast.show("Field Cannot be Empty", context,gravity: Toast.CENTER);
                              }else{
                                FeedBack feedback = FeedBack(nameController.text,feedbackController.text);
                                FeedbackService feedbackService = FeedbackService((String response){

                                });
                                feedbackService.submitForm(feedback);
                                feedbackController.clear();
                                Toast.show("Feedback Sumbited", context,gravity: Toast.CENTER);
                              }

                            },
                            child: Text("Submit"),
                          ),
                        )
                      ],
                    ),

                  ),

                ],
              ),
            );
          }else{
            return SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },


      ),
    );
  }
}
