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
  var currentIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> halaman = [
    DashboardWidget(),
    TransaksiWidget(),
    ProfileWidget(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            dashboardKey.currentState!.refreshDashboard();
          }
        },
        children: [
          DashboardWidget(key: dashboardKey),
          TransaksiWidget(),
          ProfileWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF4C75FF),
        unselectedItemColor: Color(0xFF9BA3AE),
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          _pageController.jumpToPage(index);
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

  final GlobalKey<DashboardWidgetState> dashboardKey =
      GlobalKey<DashboardWidgetState>();
}
