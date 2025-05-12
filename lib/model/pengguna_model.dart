class Pengguna {
  int? _id;
  String? _username;
  String? _password;
  String? _email;
  String? _nohp;

  Pengguna({
    int? id,
    String? username,
    String? password,
    String? email,
    String? nohp,
  }) : _id = id,
       _username = username,
       _email = email,
       _password = password,
       _nohp = nohp;

  Pengguna.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _username = json['username'];
    _password = json['password'];
    _email = json['email'];
    _nohp = json['nohp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['username'] = this._username;
    data['password'] = this._password;
    data['email'] = this._email;
    data['nohp'] = this._nohp;
    return data;
  }

  int? get id => _id;
  String? get username => _username;
  String? get password => _password;
  String? get email => _email;
  String? get nohp => _nohp;
}
