import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Pengguna {
  final int id;
  Pengguna({required this.id});

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Pengguna(id: data['id'] ?? '');
  }
}

class UbahPasswordWidget extends StatefulWidget {
  const UbahPasswordWidget({super.key});

  @override
  State<UbahPasswordWidget> createState() => _UbahPasswordWidgetState();
}

class _UbahPasswordWidgetState extends State<UbahPasswordWidget> {
  late Future<Pengguna> futurePengguna;
  Future<int?> getPenggunaIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<Pengguna> fetchPengguna(int id) async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2/backend_project_rpl/select/pengguna.php?id=$id',
      ),
    );

    if (response.statusCode == 200) {
      return Pengguna.fromJson(json.decode(response.body));
    } else {
      throw Exception('Data tidak ditemukan');
    }
  }

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmationPasswordController =
      TextEditingController();

  Future<void> _editProfile() async {
    final id = await getPenggunaIdFromPrefs();

    if (id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final url = Uri.parse(
      'http://10.0.2.2/backend_project_rpl/crud/ubah_password.php',
    );
    final response = await http.post(
      url,
      body: jsonEncode({
        "oldPassword": _oldPasswordController.text,
        "newPassword": _newPasswordController.text,
        "confirmationPassword": _confirmationPasswordController.text,
        "id": id.toString(),
      }),
    );

    if (!mounted) return;
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    textAlign: TextAlign.center,
                    'Berhasil',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Password berhasil diubah',
                    style: TextStyle(fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFF9FCFF),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 55,
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          foregroundColor: Colors.white,
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.3,
                            40,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ),
                  ],
                ),
          );

          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmationPasswordController.clear();
        } else {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Gagal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    data['message'],
                    style: TextStyle(fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFF9FCFF),
                  icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          foregroundColor: Colors.white,
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.3,
                            40,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ),
                  ],
                ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Gagal',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  textAlign: TextAlign.center,
                  'Error: ${e.toString()}',
                  style: TextStyle(fontSize: 14),
                ),
                backgroundColor: Color(0xFFF9FCFF),
                icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4C75FF),
                        foregroundColor: Colors.white,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.3,
                          40,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Gagal',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              content: Text(
                textAlign: TextAlign.center,
                'Empty response from server.',
                style: TextStyle(fontSize: 14),
              ),
              backgroundColor: Color(0xFFF9FCFF),
              icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C75FF),
                      foregroundColor: Colors.white,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.3,
                        40,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    futurePengguna = getPenggunaIdFromPrefs().then((id) {
      if (id == null) throw Exception('ID tidak ditemukan');
      return fetchPengguna(id);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Ubah Password',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          color: Color(0xFFFFFFFF),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Password lama',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    TextField(
                      obscureText: true,
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Masukan password lama',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF4C75FF)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Password baru',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    TextField(
                      obscureText: true,
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Masukan password baru',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF4C75FF)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Konfirmasi password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    TextField(
                      obscureText: true,
                      controller: _confirmationPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi password',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF4C75FF)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: Size(180, 45),
                    backgroundColor: Color(0xFF4C75FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _editProfile,
                  child: Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
