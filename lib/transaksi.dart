import 'package:flutter/material.dart';

class transaksiWidget extends StatefulWidget {
  const transaksiWidget({super.key});

  @override
  State<transaksiWidget> createState() => _transaksiWidgetState();
}

class _transaksiWidgetState extends State<transaksiWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          title: Text(
            'Tambah Transaksi',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C4C),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            dividerColor: Color(0xFF4C75FF),
            indicatorColor: Color(0xFF4C75FF),
            labelColor: Color(0xFF4C75FF),
            unselectedLabelColor: Color(0xFF9BA3AE),
            tabs: [Tab(text: 'Pemasukan'), Tab(text: 'Pengeluaran')],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 1,
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nama Transaksi',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nominal',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Keterangan',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add,
                          size: 25,
                          color: Color(0xFFF9FCFF),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          fixedSize: Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nama Transaksi',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nominal',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color: Color(0xFFF9FCFF),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Keterangan',
                            focusColor: Color(0xFF4C75FF),
                            hoverColor: Color(0xFF1A1C4C),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add,
                          size: 25,
                          color: Color(0xFFF9FCFF),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          fixedSize: Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
