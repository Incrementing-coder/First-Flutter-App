class User {
  String _username;
  String _password;
  String _email;
  User(this._username, this._password, this._email);

  User.map(dynamic obj) {
    this._username = obj["username"];
    this._email = obj['email'];
    this._password = obj["password"];
  }

  String get username => _username;
  String get email => _email;
  String get password => _password;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["email"] = _email;
    map["password"] = _password;

    return map;
  }
}