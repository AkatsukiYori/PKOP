import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Pengguna {
  final int id;
  final double pemasukan;
  final double pengeluaran;

  Pengguna({
    required this.id,
    required this.pemasukan,
    required this.pengeluaran,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Pengguna(
      id: data['id'] ?? 0,
      pemasukan: data['total_pemasukan'] ?? 0,
      pengeluaran: data['total_pengeluaran'] ?? 0,
    );
  }
}

class TransaksiWidget extends StatefulWidget {
  const TransaksiWidget({super.key});

  @override
  State<TransaksiWidget> createState() => _TransaksiWidgetState();
}

class _TransaksiWidgetState extends State<TransaksiWidget> {
  late Future<Pengguna> futurePengguna;
  double pemasukan_sekarang = 0;
  double pengeluaran_sekarang = 0;

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
      setState(() {
        pemasukan_sekarang =
            Pengguna.fromJson(json.decode(response.body)).pemasukan;
        pengeluaran_sekarang =
            Pengguna.fromJson(json.decode(response.body)).pengeluaran;
      });
      return Pengguna.fromJson(json.decode(response.body));
    } else {
      throw Exception('Data tidak ditemukan');
    }
  }

  final TextEditingController _judulTransaksiController =
      TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  String? _selectedKategori;
  String? _selectedJenis = 'pemasukan';
  DateTime? _selectedDate;

  Future<void> _addingTransaction() async {
    final id = await getPenggunaIdFromPrefs();

    if (id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final url = Uri.parse(
      'http://10.0.2.2/backend_project_rpl/crud/transaksi.php',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        "pengguna_id": id.toString(),
        "judul_transaksi": _judulTransaksiController.text,
        "tanggal": _selectedDate?.toIso8601String(),
        "kategori": _selectedKategori,
        "jenis_transaksi": _selectedJenis,
        "keterangan": _keteranganController.text,
        "nominal": _nominalController.text,
        "pemasukan": pemasukan_sekarang + double.parse(_nominalController.text),
        "pengeluaran":
            pengeluaran_sekarang + double.parse(_nominalController.text),
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
                    'Berhasil',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    textAlign: TextAlign.center,
                    'Transaksi berhasil ditambahkan',
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
                          Navigator.pop(context, true);
                        },
                        child: Text('OK'),
                      ),
                    ),
                  ],
                ),
          );

          _judulTransaksiController.clear();
          _keteranganController.clear();
          _nominalController.clear();
          _selectedKategori = null;
          _selectedJenis = 'pemasukan';
          _selectedDate = null;
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
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Tambah Transaksi',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                          'Jenis Transaksi',
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
                    DropdownButtonFormField(
                      value:
                          (_selectedJenis != '' ? _selectedJenis : 'pemasukan'),
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value;
                        });
                      },
          
                      items: [
                        DropdownMenuItem(
                          child: Text('Pemasukan'),
                          value: 'pemasukan',
                        ),
                        DropdownMenuItem(
                          child: Text('Pengeluaran'),
                          value: 'pengeluaran',
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Pilih jenis transaksi',
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
                          'Tanggal',
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
                    DateTimeFormField(
                      canClear: true,
                      dateFormat: DateFormat('dd MMM yyyy HH:mm'),
                      mode: DateTimeFieldPickerMode.dateAndTime,
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
                      firstDate: DateTime.now().subtract(Duration(days: 10950)),
                      lastDate: DateTime.now().add(Duration(days: 0)),
                      initialPickerDateTime: DateTime.now(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDate = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nama Transaksi',
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
                      controller: _judulTransaksiController,
                      decoration: InputDecoration(
                        hintText: 'Masukan nama transaksi',
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
                          'Kategori',
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
                    DropdownButtonFormField(
                      value: _selectedKategori,
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value;
                        });
                      },
                      items: [
                        if (_selectedJenis == 'pemasukan') ...[
                          DropdownMenuItem(child: Text('Gaji'), value: 'gaji'),
                          DropdownMenuItem(
                            child: Text('Dividen'),
                            value: 'dividen',
                          ),
                          DropdownMenuItem(
                            child: Text('Pemasukan Lainnya'),
                            value: 'pemasukan_lainnya',
                          ),
                        ] else ...[
                          DropdownMenuItem(
                            child: Text('Transportasi'),
                            value: 'transportasi',
                          ),
                          DropdownMenuItem(
                            child: Text('Konsumsi'),
                            value: 'konsumsi',
                          ),
                          DropdownMenuItem(
                            child: Text('Akomodasi'),
                            value: 'akomodasi',
                          ),
                          DropdownMenuItem(
                            child: Text('Edukasi'),
                            value: 'edukasi',
                          ),
                          DropdownMenuItem(
                            child: Text('Hiburan'),
                            value: 'hiburan',
                          ),
                          DropdownMenuItem(
                            child: Text('Kesehatan'),
                            value: 'kesehatan',
                          ),
                          DropdownMenuItem(
                            child: Text('Investasi'),
                            value: 'investasi',
                          ),
                        ],
                      ],
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori',
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
                          'Nominal',
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
                      controller: _nominalController,
                      decoration: InputDecoration(
                        hintText: 'Masukan nominal',
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
                    Text(
                      'Keterangan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _keteranganController,
                      decoration: InputDecoration(
                        hintText: 'Masukan keterangan',
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
                  onPressed: _addingTransaction,
                  child: Text(
                    "Tambah Transaksi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
