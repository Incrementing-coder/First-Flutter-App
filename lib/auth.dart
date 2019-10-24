import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/rest_auth/rest_ds.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  var currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  RestDatasource api = new RestDatasource();

  AuthService() {
    print("new AuthService");
  }

  Future getUser() async {
    //print(currentUser);
    if (await _auth.currentUser() != null) {
      this.currentUser = _auth.currentUser();
      return Future.value(currentUser);
    } else if (await _read() != null) {
      this.currentUser = await _read();
      return Future.value(currentUser);
    } else {
      return Future.value(currentUser);
    }
  }

  // wrapping the firebase calls
  Future logout() async {
    // If logged in through Google
    if (await _auth.currentUser() != null) {
      var res = await _auth.signOut();
      var gres = await googleSignIn.signOut();
      currentUser = null;
      await _save(null).then((val) {
        notifyListeners();
      });
      print("Logged out of google");
      return res;
    }
    // If logged in Manually
    else {
      this.currentUser = null;
      await api.logout().then((val) => print(val));
      await _save(null).then((val) {
        notifyListeners();
      });
      print("Logged out");
      return Future.value(currentUser);
    }
  }

  Future _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? null;

    return value;
  }

  Future _save(String val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.setString(key, val) ?? null;

    return value;
  }

  // wrapping the firebase calls
  Future createUser(
      {String username, String email, String pass1, String pass2}) async {
    await api.createAccount(username, email, pass1, pass2).then((var token) {
      currentUser = token;
      print("set token and curr user " + currentUser);
      _save(currentUser);
      notifyListeners();
      return Future.value(currentUser);
    }).catchError((Object error) => print(error.toString()));
  }

  // TODO Solve future
  Future loginUser(String username, String password) async {
    await api.login(username, password).then((var token) {
      currentUser = token;
      print("set token and curr user " + currentUser);
      _save(currentUser);
      notifyListeners();
      return Future.value(currentUser);
    }).catchError((Object error) => print(error.toString()));
  }

  Future<FirebaseUser> loginUsingGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    // Checking if email and name is null
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoUrl != null);

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currUser = await _auth.currentUser();
    assert(user.uid == currUser.uid);
    await _save(user.displayName).then((val) {
      notifyListeners();
    });
    this.currentUser = user;
    return Future.value(currentUser);
  }
}
