import 'package:flutter/material.dart';
import 'package:project_rpl/home.dart';
import 'package:project_rpl/profile.dart';
import 'package:project_rpl/transaksi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var index = 0;
  List<Widget> halaman = [homeWidget(), transaksiWidget(), profileWidget()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: halaman[index],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xFF4C75FF),
          unselectedItemColor: Color(0xFF9BA3AE),
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          iconSize: 30,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Tambah Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
