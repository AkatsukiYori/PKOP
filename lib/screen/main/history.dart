import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';

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
  final String? kategori;

  Transaksi({
    this.judul_transaksi,
    this.keterangan,
    this.nominal,
    this.tanggal,
    this.jenis_transaksi,
    this.kategori,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      judul_transaksi: json['judul_transaksi'],
      keterangan: json['keterangan'],
      nominal: json['nominal'],
      tanggal: json['tanggal'],
      jenis_transaksi: json['jenis_transaksi'],
      kategori: json['kategori'],
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
  final DateFormat formatter = DateFormat('MMMM yyyy');
  DateTime? selectedDate;

  Future<void> _pickMonthYear() async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      firstDate: DateTime(1990, 1),
      lastDate: DateTime(now.year, 12),
      initialDate: selectedDate ?? now,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

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

  Future<List<Transaksi>> fetchTransaksi(int pengguna_id) async {
    final pengguna_id = await getPenggunaIdFromPrefs();
    if (pengguna_id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2/backend_project_rpl/select/get_transaksi.php?id=$pengguna_id&limit=false',
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

  Future<void> exportExcel(List<Transaksi> transaksiList) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Set header row
    sheet.getRangeByName('A1').setText('Nomor');
    sheet.getRangeByName('B1').setText('Tanggal');
    sheet.getRangeByName('C1').setText('Jenis Transaksi');
    sheet.getRangeByName('D1').setText('Judul Transaksi');
    sheet.getRangeByName('E1').setText('Kategori');
    sheet.getRangeByName('F1').setText('Nominal');
    sheet.getRangeByName('G1').setText('Keterangan');

    // Fill data into the worksheet
    for (int i = 0; i < transaksiList.length; i++) {
      final trx = transaksiList[i];
      sheet.getRangeByIndex(i + 2, 1).setNumber(i + 1);
      sheet.getRangeByIndex(i + 2, 2).setText(trx.tanggal ?? '');
      sheet.getRangeByIndex(i + 2, 3).setText(trx.jenis_transaksi ?? '');
      sheet.getRangeByIndex(i + 2, 4).setText(trx.judul_transaksi ?? '');
      sheet.getRangeByIndex(i + 2, 5).setText(trx.kategori ?? '');
      sheet.getRangeByIndex(i + 2, 6).setNumber((trx.nominal ?? 0).toDouble());
      sheet.getRangeByIndex(i + 2, 7).setText(trx.keterangan ?? '');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/transaksi.xlsx';

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Berhasil',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            content: Text(
              textAlign: TextAlign.center,
              'Transaksi berhasil di export',
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
  }

  // Flutter web export excel
  // void downloadExcel(Uint8List bytes, String filename) {
  //   final blob = html.Blob([bytes]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   html.AnchorElement(href: url)
  //     ..setAttribute('download', filename)
  //     ..click();
  //   html.Url.revokeObjectUrl(url);
  // }

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
          final List<Transaksi> allTransaksi =
              snapshot.data!['transaksi'] as List<Transaksi>;
          final List<Transaksi> transaksiList =
              selectedDate == null
                  ? allTransaksi
                  : allTransaksi.where((trx) {
                    if (trx.tanggal != null) {
                      final filter = DateTime.parse(trx.tanggal!);
                      return filter.month == selectedDate!.month &&
                          filter.year == selectedDate!.year;
                    } else {
                      return false;
                    }
                  }).toList();
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
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                readOnly: true,
                                onTap: _pickMonthYear,
                                decoration: InputDecoration(
                                  focusColor: Colors.black,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  labelText: 'Pilih periode',
                                  hintText: 'MM/YYYY',
                                ),
                                controller: TextEditingController(
                                  text:
                                      selectedDate != null
                                          ? formatter.format(selectedDate!)
                                          : '',
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () async {
                                final transaksi =
                                    selectedDate == null
                                        ? allTransaksi
                                        : allTransaksi.where((trx) {
                                          if (trx.tanggal != null) {
                                            final filter = DateTime.parse(
                                              trx.tanggal!,
                                            );
                                            return filter.month ==
                                                    selectedDate!.month &&
                                                filter.year ==
                                                    selectedDate!.year;
                                          } else {
                                            return false;
                                          }
                                        }).toList();

                                // if (kIsWeb) {
                                //   final xlsio.Workbook workbook =
                                //       xlsio.Workbook();
                                //   final xlsio.Worksheet sheet =
                                //       workbook.worksheets[0];
                                //   // Set header row
                                //   // Styling
                                //   final xlsio.Style globalStyle = workbook
                                //       .styles
                                //       .add('globalStyle');
                                //   globalStyle.borders.all.lineStyle =
                                //       xlsio.LineStyle.thin;
                                //   globalStyle.borders.all.color = '#000000';
                                //   sheet.getRangeByName('A1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('B1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('C1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('D1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('E1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('F1').cellStyle =
                                //       globalStyle;
                                //   sheet.getRangeByName('G1').cellStyle =
                                //       globalStyle;

                                //   sheet.getRangeByName('A1').cellStyle.bold =
                                //       true;
                                //   sheet.getRangeByName('B1').cellStyle.bold =
                                //       sheet
                                //           .getRangeByName('C1')
                                //           .cellStyle
                                //           .bold = true;
                                //   sheet.getRangeByName('D1').cellStyle.bold =
                                //       true;
                                //   sheet.getRangeByName('E1').cellStyle.bold =
                                //       true;
                                //   sheet.getRangeByName('F1').cellStyle.bold =
                                //       true;
                                //   sheet.getRangeByName('G1').cellStyle.bold =
                                //       true;
                                //   true;

                                //   sheet.getRangeByName('A1').setText('Nomor');
                                //   sheet.getRangeByName('B1').setText('Tanggal');
                                //   sheet
                                //       .getRangeByName('C1')
                                //       .setText('Jenis Transaksi');
                                //   sheet
                                //       .getRangeByName('D1')
                                //       .setText('Judul Transaksi');
                                //   sheet
                                //       .getRangeByName('E1')
                                //       .setText('Kategori');
                                //   sheet.getRangeByName('F1').setText('Nominal');
                                //   sheet
                                //       .getRangeByName('G1')
                                //       .setText('Keterangan');

                                //   // Fill data into the worksheet
                                //   for (
                                //     int i = 0;
                                //     i < transaksiList.length;
                                //     i++
                                //   ) {
                                //     final trx = transaksiList[i];
                                //     sheet.getRangeByIndex(i + 2, 1).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 2).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 3).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 4).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 5).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 6).cellStyle =
                                //         globalStyle;
                                //     sheet.getRangeByIndex(i + 2, 7).cellStyle =
                                //         globalStyle;

                                //     sheet
                                //         .getRangeByIndex(i + 2, 1)
                                //         .setNumber(i + 1);
                                //     sheet
                                //         .getRangeByIndex(i + 2, 2)
                                //         .setText(trx.tanggal ?? '');
                                //     sheet
                                //         .getRangeByIndex(i + 2, 3)
                                //         .setText(trx.jenis_transaksi ?? '');
                                //     sheet
                                //         .getRangeByIndex(i + 2, 4)
                                //         .setText(trx.judul_transaksi ?? '');
                                //     sheet
                                //         .getRangeByIndex(i + 2, 5)
                                //         .setText(trx.kategori ?? '');
                                //     sheet
                                //         .getRangeByIndex(i + 2, 6)
                                //         .setNumber(
                                //           (trx.nominal ?? 0).toDouble(),
                                //         );
                                //     sheet
                                //         .getRangeByIndex(i + 2, 7)
                                //         .setText(trx.keterangan ?? '-');
                                //   }

                                //   final List<int> bytes =
                                //       workbook.saveAsStream();
                                //   workbook.dispose();
                                //   downloadExcel(
                                //     Uint8List.fromList(bytes),
                                //     'transaksi.xlsx',
                                //   );
                                // } else {
                                  await exportExcel(transaksi);
                                // }
                              },
                              icon: Icon(Icons.file_download_outlined),
                              iconSize: 28,
                              tooltip: 'Export Excel',
                            ),
                          ],
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
