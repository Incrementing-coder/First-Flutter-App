import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _tempPass;
  String _vpassword;
  String _email;
  String _username;
  bool _isLoading = false;
  bool _isValid = false;
  bool _isDValid = false;
  bool _isValidEmail = false;

  final textSize = const TextStyle(fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new Stack(fit: StackFit.expand, children: <Widget>[
        new Image(
          image: new AssetImage("assets/girl.jpeg"),
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black87,
        ),
        new Theme(
          data: new ThemeData(
              brightness: Brightness.dark,
              inputDecorationTheme: new InputDecorationTheme(
                labelStyle:
                    new TextStyle(color: Colors.tealAccent, fontSize: 25.0),
              )),
          isMaterialAppTheme: true,
          child: _isLoading
              ? Center(child: const CircularProgressIndicator())
              : new SingleChildScrollView(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Padding(padding: const EdgeInsets.only(top: 100.0)),
                      new FlutterLogo(
                        size: 140.0,
                      ),
                      new Container(
                        padding: const EdgeInsets.all(40.0),
                        child: new Form(
                          key: _formKey,
                          autovalidate: true,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new TextFormField(
                                onSaved: (value) => _username = value,
                                decoration: new InputDecoration(
                                    labelText: "Enter Username",
                                    labelStyle: textSize,
                                    fillColor: Colors.white),
                                keyboardType: TextInputType.text,
                              ),
                              new TextFormField(
                                onSaved: (value) => _email = value,
                                onChanged: (text) {
                                  if (validateEmail(text))
                                    setState(() {
                                      _isValidEmail = true;
                                    });
                                  else
                                    setState(() {
                                      _isValidEmail = false;
                                    });
                                },
                                decoration: new InputDecoration(
                                  labelText: "Enter Email",
                                  icon: _isValidEmail
                                      ? new Icon(
                                          FontAwesomeIcons.check,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      : null,
                                  labelStyle: textSize,
                                ),
                                obscureText: false,
                                keyboardType: TextInputType.text,
                              ),
                              new TextFormField(
                                onSaved: (value) => _password = value,
                                onChanged: (text) {
                                  setState(() {
                                    _isDValid = false;
                                  });
                                  bool valid = validatePassword(text);
                                  if (valid)
                                    setState(() {
                                      _isValid = true;
                                      _tempPass = text;
                                    });
                                  else {
                                    setState(() {
                                      _isValid = false;
                                      _tempPass = text;
                                    });
                                  }
                                },
                                decoration: new InputDecoration(
                                  labelText: "Enter Password",
                                  icon: _isValid
                                      ? new Icon(
                                          FontAwesomeIcons.check,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      : null,
                                  labelStyle: textSize,
                                ),
                                obscureText: true,
                                keyboardType: TextInputType.text,
                              ),
                              new TextFormField(
                                onSaved: (value) => _vpassword = value,
                                onChanged: (text) {
                                  if (text == _tempPass)
                                    setState(() {
                                      _isDValid = true;
                                    });
                                  else
                                    setState(() {
                                      _isDValid = false;
                                    });
                                },
                                decoration: new InputDecoration(
                                  labelText: "Enter Password again",
                                  icon: _isDValid
                                      ? new Icon(
                                          FontAwesomeIcons.check,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      : null,
                                  labelStyle: textSize,
                                ),
                                obscureText: true,
                                keyboardType: TextInputType.text,
                              ),
                              new Padding(
                                padding: const EdgeInsets.only(top: 60.0),
                              ),
                              new MaterialButton(
                                height: 50.0,
                                minWidth: 150.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                color: Colors.green,
                                splashColor: Colors.teal,
                                textColor: Colors.white,
                                child: new Icon(FontAwesomeIcons.check),
                                onPressed: () async {
                                  final form = _formKey.currentState;
                                  form.save();

                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    var user;
                                    user =
                                        await Provider.of<AuthService>(context)
                                            .createUser(
                                                username: _username,
                                                email: _email,
                                                pass1: _password,
                                                pass2: _vpassword)
                                            .then((val) {
                                      user = val;
                                    });

                                    if (await _read() != null) {
                                      user = await _read();
                                    } else
                                      _buildErrorDialog(
                                          context,
                                          "Please provide the information correctly. \n"
                                          "-Password should have min 1 uppercase, 1 lowercase, 1 digit, 1 special character.");


                                    setState(() => _isLoading = false);
                                    Navigator.pop(context);
                                  }

                                  // Validate will return true if is valid, or false if invalid.
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  bool validatePassword(String text) {
    Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = new RegExp(pattern);

    return regex.hasMatch(text);
  }

  bool validateEmail(String text) {
    Pattern pattern = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)";
    RegExp regex = new RegExp(pattern);

    return regex.hasMatch(text);
  }

  Future _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? null;

    return value;
  }
}
