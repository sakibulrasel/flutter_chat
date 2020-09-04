import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/pages/home_page.dart';

import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../services/db_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  AuthStatus status;

  FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      await DBService.instance.getUsername().then((value) async{
        if(value==null){
          return NavigationService.instance.navigateToReplacement("register");
        }else{
          await DBService.instance.updateUserLastSeenTime(user.uid);
          return NavigationService.instance.navigateToReplacement("home");
        }
      });


    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    // _auth.signOut();
    user = await _auth.currentUser();
    if (user != null) {
      await DBService.instance.getUsername().then((value) async{
        if(value==null){
          return NavigationService.instance.navigateToReplacement("register");
        }else{
          notifyListeners();
          await _autoLogin();
        }
      });
    }
  }

  void loginWithPhoneNumber(AuthCredential credential, BuildContext context) async{
    AuthResult result = await _auth.signInWithCredential(credential);

    user = result.user;
    DBService.instance.getUsername().then((value) async{

      if(value!=null){
        Navigator.of(context).pop();

        if(user != null){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomePage()
          ));
        }else{
          print("Error");
        }
      }else{
        NavigationService.instance.navigateTo("register");
      }
    });
  }

  void loginUserWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      await DBService.instance.updateUserLastSeenTime(user.uid);
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error Authenticating");
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      await DBService.instance.updateUserLastSeenTime(user.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error Registering User");
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully!");
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Logging Out");
    }
    notifyListeners();
  }
}
