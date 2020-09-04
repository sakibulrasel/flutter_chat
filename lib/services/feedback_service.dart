import '../models/feedback.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FeedbackService {
  // Callback function to give response of status of current request.
  final void Function(String) callback;

  // Google App Script Web URL
  static const String URL = "https://script.google.com/macros/s/AKfycbzVMmy4WB87R4xcEiQZAg6nTeuzjqbNwgAwxeMYGJdlNfLtmLAg/exec";

  static const STATUS_SUCCESS = "SUCCESS";

  FeedbackService(this.callback);

  void submitForm(FeedBack feedbackForm) async{
    try{
      await http.get(URL + feedbackForm.toParams()).then(
              (response){

            callback(convert.jsonDecode(response.body)['status']);
          });
    } catch(e){
      print(e);
    }
  }
}