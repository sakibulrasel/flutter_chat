import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';
import '../services/snackbar_service.dart';
import '../services/location_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}


class _RegistrationPageState extends State<RegistrationPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _name;
//  String _email;
//  String _password;
  File _image;
  String _location;
  GeoPoint _geoPosition;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }


//  void _setLocation() async {
//    await getLocationString().then((value){
//      setState(() {
//        _location = value;
//      });
//      _geoPosition = createGeoPoint(_location);
//    });
//
//  }

  @override
  void initState() {
    getLocationString().then((value){
      setState(() {
        _location = value;
        _geoPosition = createGeoPoint(value);
      });
    });
//    _setLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);

        return Container(
          height: _deviceHeight * 0.75,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(),
              _inputForm(),
              _registerButton(),
//              _backToLoginPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Register.",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
//            _emailTextField(),
//            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.12,
          width: _deviceHeight * 0.12,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _image != null
                  ? FileImage(_image)
                  : NetworkImage(
                  "https://creazilla-store.fra1.digitaloceanspaces.com/cliparts/5652/goose-head-clipart-md.png"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return _input.length != 0 ? null : "Please enter a name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

//  Widget _emailTextField() {
//    return TextFormField(
//      autocorrect: false,
//      style: TextStyle(color: Colors.white),
//      validator: (_input) {
//        return _input.length != 0 && _input.contains("@")
//            ? null
//            : "Please enter a valid email";
//      },
//      onSaved: (_input) {
//        setState(() {
//          _email = _input;
//        });
//      },
//      cursorColor: Colors.white,
//      decoration: InputDecoration(
//        hintText: "Email",
//        focusedBorder: UnderlineInputBorder(
//          borderSide: BorderSide(color: Colors.white),
//        ),
//      ),
//    );
//  }

//  Widget _passwordTextField() {
//    return TextFormField(
//      autocorrect: false,
//      obscureText: true,
//      style: TextStyle(color: Colors.white),
//      validator: (_input) {
//        return _input.length != 0 ? null : "Please enter a password";
//      },
//      onSaved: (_input) {
//        setState(() {
//          _password = _input;
//        });
//      },
//      cursorColor: Colors.white,
//      decoration: InputDecoration(
//        hintText: "Password",
//        focusedBorder: UnderlineInputBorder(
//          borderSide: BorderSide(color: Colors.white),
//        ),
//      ),
//    );
//  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () async {
//          _setLocation();
          if (_formKey.currentState.validate() && _image != null) {
            var user= await FirebaseAuth.instance.currentUser();
            var _result = await CloudStorageService.instance
                .uploadUserImage(user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance
                .createUserInDB(user.uid, _name, _imageURL, false, _location, _geoPosition);
//                      .createUserInDB(_uid, _name, _email, _imageURL, false);
            // added by Derek
            await DBService.instance.updateUserLocation(user.uid);
            NavigationService.instance.navigateToReplacement("home");
          }
        },
        color: Colors.blue,
        child: Text(
          "Register",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    ) : Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
    );
  }

//  Widget _backToLoginPageButton() {
//    return GestureDetector(
//      onTap: () {
//        NavigationService.instance.goBack();
//      },
//      child: Container(
//        height: _deviceHeight * 0.06,
//        width: _deviceWidth,
//        child: Icon(Icons.arrow_back, size: 40),
//      ),
//    );
//  }
}


