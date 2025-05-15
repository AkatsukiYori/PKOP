import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_rpl/screen/main/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_rpl/screen/auth/login.dart';
import 'package:project_rpl/screen/auth/ubah_password.dart';

class Pengguna {
  final int id;
  final String username;
  final String password;
  final String email;
  final String no_hp;

  Pengguna({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.no_hp,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Pengguna(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      email: data['email'] ?? '',
      no_hp: data['nomor_hp'] ?? '',
    );
  }
}

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  Future<int?> getPenggunaIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Stream<Pengguna> fetchPengguna(Duration interval) async* {
    while (true) {
      final id = await getPenggunaIdFromPrefs();
      final response = await http.get(
        Uri.parse(
          'http://localhost/backend_project_rpl/select/pengguna.php?id=$id',
        ),
      );

      if (response.statusCode == 200) {
        yield Pengguna.fromJson(json.decode(response.body));
        await Future.delayed(interval);
      } else {
        throw Exception('Data tidak ditemukan');
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: StreamBuilder<Pengguna>(
        stream: fetchPengguna(Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final pengguna = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 55, vertical: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                color: Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${pengguna.username}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${pengguna.email}',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9BA3AE)),
                    ),
                    Text(
                      '${pengguna.no_hp}',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9BA3AE)),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.34,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0x55DBEBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0x664C75FF),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Pemasukan',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rp 217.000.000',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 45,
                                    width: 5,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1A1C4C),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Pengeluaran',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rp 100.000.000',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PengaturanWidget(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Ubah Profile',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => UbahPasswordWidget(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.key,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Ganti Password',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginWidget(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Keluar',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.4,
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       TextButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => PengaturanWidget(),
                    //             ),
                    //           );
                    //         },
                    //         style: TextButton.styleFrom(
                    //           backgroundColor: Color(0xFF4C75FF),
                    //           fixedSize: Size(180, 40),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         child: Text(
                    //           'Pengaturan',
                    //           style: TextStyle(
                    //             color: Color(0xFFF9FCFF),
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(height: 10),
                    //       TextButton(
                    //         onPressed: () {},
                    //         style: TextButton.styleFrom(
                    //           backgroundColor: Color(0xFF4C75FF),
                    //           fixedSize: Size(180, 40),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         child: Text(
                    //           'Logout',
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             color: Color(0xFFF9FCFF),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
