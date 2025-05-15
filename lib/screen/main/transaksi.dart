import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Pengguna {
  final int id;

  Pengguna({required this.id});

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Pengguna(id: data['id'] ?? '');
  }
}

class TransaksiWidget extends StatefulWidget {
  const TransaksiWidget({super.key});

  @override
  State<TransaksiWidget> createState() => _TransaksiWidgetState();
}

class _TransaksiWidgetState extends State<TransaksiWidget> {
  late Future<Pengguna> futurePengguna;
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

  final TextEditingController _judulTransaksiController =
      TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  String? _selectedKategori;
  String? _selectedJenis = 'pemasukan';
  DateTime? _selectedDate;

  bool _isLoading = false;
  String _message = '';

  Future<void> _addingTransaction() async {
    final id = await getPenggunaIdFromPrefs();

    if (id == null) {
      throw Exception('ID tidak ditemukan');
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse(
      'http://localhost/backend_project_rpl/crud/transaksi.php',
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
      }),
    );

    if (!mounted) return;

    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _message = data['message'];
        });

        if (data['status'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tambah transaksi berhasil')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${data['message']}')));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _message = 'Error parsing response: ${e.toString()}';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } else {
      setState(() {
        _isLoading = false;
        _message = "Empty response from server.";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Empty response from server.")));
      });
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
        color: Color(0xFFFFFFFF),
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
    );
  }
}
