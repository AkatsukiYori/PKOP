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
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Pengaturan',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Color(0xFFFFFFFF),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'Ganti Nama Pengguna',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'Ganti Email Tertaut',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'Ganti Nomor Handphone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
