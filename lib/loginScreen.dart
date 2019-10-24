import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _username;
  bool _isLoading = false;

  String t = "Test";

  final textSize = const TextStyle(fontSize: 16.0);

  Animation<double> _iconAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 500));
    _iconAnimation = new CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );
    _iconAnimation.addListener(() => this.setState(() {}));
    _animationController.forward();
  }

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
                        size: _iconAnimation.value * 140.0,
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
                                onSaved: (value) => _password = value,
                                decoration: new InputDecoration(
                                  labelText: "Enter Password",
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
                                child: new Icon(FontAwesomeIcons.signInAlt),
                                onPressed: () async {
                                  final form = _formKey.currentState;
                                  form.save();

                                  // Validate will return true if is valid, or false if invalid.
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    var user;
                                    user =
                                        await Provider.of<AuthService>(context)
                                            .loginUser(_username, _password)
                                            .then((val) {
                                      user = val;
                                    });
                                    if(await _read() != null){
                                      user = await _read();
                                    }
                                    else
                                      _buildErrorDialog(context, "Incorrect Login Credentials");

                                    setState(() => _isLoading = false);
                                  }
                                },
                              ),
                              new Padding(
                                  padding: const EdgeInsets.only(top: 25.0)),
                              new GestureDetector(
                                child: new Text(
                                  "Create Account",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16.0),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/create');
                                },
                              ),
                              new Padding(
                                  padding: const EdgeInsets.only(top: 25.0)),
                              new Text(
                                "OR",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                              ),
                              new Padding(
                                  padding: const EdgeInsets.only(top: 25.0)),
                              _signInButton(),
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

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        setState(() => _isLoading = true);
        FirebaseUser user =
            await Provider.of<AuthService>(context).loginUsingGoogle();

        setState(() => _isLoading = false);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? null;

    return value;
  }
}
