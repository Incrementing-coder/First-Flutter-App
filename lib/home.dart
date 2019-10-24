import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth.dart';
import 'package:provider/provider.dart';

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

enum Settings { Logout }

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);


  Widget _buildRow(WordPair pair) {
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    //SharedPreferencesHelper.getToken().then((val) => print(val));
    return new WillPopScope(
        child: new Scaffold(
          appBar: AppBar(
            title: Text('Hello'),
            actions: <Widget>[
              PopupMenuButton<Settings>(
                onSelected: (Settings result ) async {
                  if(result == Settings.Logout){
                    await Provider.of<AuthService>(context).logout();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Settings>>[
                  const PopupMenuItem(
                      value: Settings.Logout,
                      child: Text('Logout'),),
                ]
              )
            ],
          ),
          body: _buildSuggestions(),
        ),
        onWillPop: _onBackPressed);

  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Unsaved data will be lost.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }
}

