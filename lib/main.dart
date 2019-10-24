import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/auth.dart';
import 'package:flutter_app/create_account.dart';
import 'package:flutter_app/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/loginScreen.dart';

void main() => runApp(ChangeNotifierProvider<AuthService>(
      child: MyApp(),
      builder: (BuildContext context) {
        return AuthService();
      },
    ));

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Name Generator',
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginScreen(),
        '/create': (context) => Register(),
      },
      home: FutureBuilder(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.hasData
                ? RandomWords()
                : LoginScreen();
          } else {
            return LoadingCircle();
          }
        },
      ),
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
