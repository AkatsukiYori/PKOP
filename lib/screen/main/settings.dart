import 'package:flutter/material.dart';

class PengaturanWidget extends StatefulWidget {
  const PengaturanWidget({super.key});

  @override
  State<PengaturanWidget> createState() => _PengaturanWidgetState();
}

class _PengaturanWidgetState extends State<PengaturanWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Pengaturan',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: 70,
              child: Card(
                color: Color(0xFFF9FCFF),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Color(0xFF4C75FF), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Ganti Nama Pengguna',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: 70,
              child: Card(
                color: Color(0xFFF9FCFF),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.alternate_email_outlined,
                        color: Color(0xFF4C75FF),
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Ganti Email Tertaut',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: 70,
              child: Card(
                color: Color(0xFFF9FCFF),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, color: Color(0xFF4C75FF), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Ganti Nomor Handphone',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: 70,
              child: Card(
                color: Color(0xFFF9FCFF),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.key, color: Color(0xFF4C75FF), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Ganti Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF4C75FF),
                  foregroundColor: Color(0xFFFFFFFF),
                  fixedSize: Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
