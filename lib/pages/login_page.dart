import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/home_page.dart';
import 'package:flutter_chat/pages/login_page1.dart';
import 'package:flutter_chat/pages/otp_page.dart';
import 'package:flutter_chat/services/db_service.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../providers/auth_provider.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../theme.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  double _deviceHeight;
  double _deviceWidth;
  String _code;
  String signature = "{{ app signature }}";

  GlobalKey<FormState> _formKey;
  AuthProvider auth;
  TextEditingController phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String _email;
  String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  String text = '';

  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
        child: Center(
            child: Text(text[position], style: TextStyle(color: Colors.black),)
        ),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
      );
    }
  }

  Future<bool> loginUser(String phone, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),

        verificationCompleted: (AuthCredential credential) async{
//          await auth.loginWithPhoneNumber(credential,context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          new CircularProgressIndicator(),
                          new Text("Success Loggin in.."),
                        ],
                      ),
                    );
                  },
                );

                new Future.delayed(new Duration(seconds: 3), () async {
                  await auth.loginWithPhoneNumber(credential,context);
                });
          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) async{

          NavigationService.instance.navigateToRoute(
            MaterialPageRoute(builder: (context) {
              return OtpPage(verificationId);
            }),
          );
        },
        codeAutoRetrievalTimeout: null
    );
  }


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {

    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                height: 240,
                                constraints: const BoxConstraints(
                                    maxWidth: 500
                                ),
                                margin: const EdgeInsets.only(top: 100),
                                decoration: const BoxDecoration(color: Color(0xFFE1E0F5), borderRadius: BorderRadius.all(Radius.circular(30))),
                              ),
                            ),
                            Center(
                              child: Container(
                                  constraints: const BoxConstraints(maxHeight: 340),
                                  margin: const EdgeInsets.only(top: 60),
                                  padding: const EdgeInsets.all(50),
                                  child: Image.asset('assets/img/login.png',fit: BoxFit.cover,)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Goose',
                              style: TextStyle(color: MyColors.primaryColor, fontSize: 30, fontWeight: FontWeight.w800)))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Container(
                          constraints: const BoxConstraints(
                              maxWidth: 500
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(text: 'We will send you an ', style: TextStyle(color: MyColors.primaryColor)),
                              TextSpan(
                                  text: 'One Time Password ', style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold)),
                              TextSpan(text: 'on this mobile number', style: TextStyle(color: MyColors.primaryColor)),
                            ]),
                          )),
                      Container(
                        height: 40,
                        constraints: const BoxConstraints(
                            maxWidth: 500
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: CupertinoTextField(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(4))
                          ),
                          controller: phoneController,
                          clearButtonMode: OverlayVisibilityMode.editing,
                          keyboardType: TextInputType.phone,
                          maxLines: 1,
                          placeholder: '+88...',
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        constraints: const BoxConstraints(
                            maxWidth: 500
                        ),
                        child: RaisedButton(
                          onPressed: () {

                            if (phoneController.text.isNotEmpty) {
                               loginUser(phoneController.text, context);
                            } else {
                              SnackBarService.instance.showSnackBarError("Please Enter Your Phone Number");
                            }
                          },
                          color: MyColors.primaryColor,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                    color: MyColors.primaryColorLight,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


}
