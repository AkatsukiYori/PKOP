import 'package:flutter/material.dart';
import 'package:project_rpl/screen/main/dashboard.dart';
import 'package:project_rpl/screen/main/transaksi.dart';
import 'package:project_rpl/screen/main/profile.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  var index = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> halaman = [
      DashboardWidget(),
      TransaksiWidget(),
      ProfileWidget(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
    );
  }
}
