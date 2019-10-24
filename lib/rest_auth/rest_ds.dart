import 'dart:async';
import 'package:flutter_app/utils/network_util.dart';


class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "https://auth-backend-1.herokuapp.com";
  static final LOGIN_URL = BASE_URL + "/api/v1/rest-auth/login/";
  static final CREATE_URL = BASE_URL + "/api/v1/rest-auth/registration/";
  static final LOGOUT_URL = BASE_URL + "/api/v1/rest-auth/logout/";

  Future<String> login(String username, String password) {
    return _netUtil.post(LOGIN_URL, body: {
      "username": username,
      "password": password
    }).then((dynamic res) {

      if(res["non_field_errors"] != null) return null;

      return res["key"];
    });
  }

  Future<String> createAccount(String username, String email, String password1, String password2){
    return _netUtil.create(CREATE_URL, body: {
      "username": username,
      "email": email,
      "password1": password1,
      "password2": password2
    }).then((dynamic res) {
      print(res);
      if(res["email"] != null) return null;

      return res["key"];
    });
  }

  Future<String> logout() {
    return _netUtil.post(LOGOUT_URL).then((dynamic res) {

      if(res["non_field_errors"] != null) return null;

      return res["detail"];
    });
  }
}