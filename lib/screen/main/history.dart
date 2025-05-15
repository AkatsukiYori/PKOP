import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';

class Pengguna {
  final String username;

  Pengguna({required this.username});

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Pengguna(username: data['username'] ?? '');
  }
}

class Transaksi {
  final String? judul_transaksi;
  final String? keterangan;
  final int? nominal;
  final String? tanggal;
  final String? jenis_transaksi;

  Transaksi({
    this.judul_transaksi,
    this.keterangan,
    this.nominal,
    this.tanggal,
    this.jenis_transaksi,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      judul_transaksi: json['judul_transaksi'],
      keterangan: json['keterangan'],
      nominal: json['nominal'],
      tanggal: json['tanggal'],
      jenis_transaksi: json['jenis_transaksi'],
    );
  }
}

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late Future<Pengguna> futurePengguna;
  late Future<Map<String, dynamic>> futureTransaksi;

  Future<int?> getPenggunaIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<Pengguna> fetchPengguna(int id) async {
    final response = await http.get(
      Uri.parse(
        'http://localhost/backend_project_rpl/select/pengguna.php?id=$id',
      ),
    );

    if (response.statusCode == 200) {
      return Pengguna.fromJson(json.decode(response.body));
    } else {
      throw Exception('Data tidak ditemukan');
    }
  }

  Future<List<Transaksi>> fetchTransaksi(int pengguna_id) async {
    final pengguna_id = await getPenggunaIdFromPrefs();
    if (pengguna_id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse(
        'http://localhost/backend_project_rpl/select/get_transaksi.php?id=$pengguna_id&limit=false',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> loop_data = data['data'];

      if (data['status'] == true) {
        final List<Transaksi> transaksiList =
            loop_data.map((item) => Transaksi.fromJson(item)).toList();
        return transaksiList;
      } else {
        throw Exception('Data tidak ditemukan');
      }
    } else {
      throw Exception('Server error');
    }
  }

  Stream<Map<String, dynamic>> getTransaksi(Duration interval) async* {
    final pengguna_id = await getPenggunaIdFromPrefs();
    if (pengguna_id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final transaksi = await fetchTransaksi(pengguna_id);
    yield {'transaksi': transaksi};
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
    return StreamBuilder<Map<String, dynamic>>(
      stream: getTransaksi(Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final transaksiList = snapshot.data!['transaksi'] as List<Transaksi>;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xFFFFFFFF),
              title: Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Container(
                color: Color(0xFFFFFFFF),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: DateTimeFormField(
                          canClear: true,
                          dateFormat: DateFormat('dd MMM yyyy'),
                          mode: DateTimeFieldPickerMode.date,
                          decoration: InputDecoration(
                            hintText: 'Pilih tanggal',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF4C75FF)),
                            ),
                          ),
                          firstDate: DateTime.now().subtract(
                            Duration(days: 10950),
                          ),
                          lastDate: DateTime.now().add(Duration(days: 0)),
                          initialPickerDateTime: DateTime.now(),
                          onChanged: (value) {
                            // setState(() {
                            //   _selectedDate = value;
                            // });
                          },
                        ),
                      ),
                      transaksiList.isEmpty
                          ? Text(
                            'Tidak ada transaksi',
                            style: TextStyle(fontSize: 18),
                          )
                          : Column(
                            children: [
                              ...transaksiList.map((trx) {
                                final formattedTanggal = DateFormat(
                                  'dd MMM yyyy HH:mm',
                                ).format(DateTime.parse(trx.tanggal ?? ''));
                                final formattedNominal = NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp',
                                  decimalDigits: 0,
                                ).format(trx.nominal);
                                final iconChange =
                                    (trx.jenis_transaksi == 'pemasukan'
                                        ? Icons.add
                                        : Icons.horizontal_rule);
                                final textColor =
                                    (trx.jenis_transaksi == 'pemasukan'
                                        ? Colors.green
                                        : Colors.redAccent);

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 2,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0x55DBEBFF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Color(0x664C75FF),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4C75FF),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Icon(
                                          iconChange,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      title: Text(
                                        trx.judul_transaksi ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${trx.keterangan ?? ''} ${formattedTanggal} WIB',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: Text(
                                        formattedNominal,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
