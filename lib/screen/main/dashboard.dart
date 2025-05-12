import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late Future<Pengguna> futurePengguna;
  late Future<Map<String, dynamic>> combineFuture;
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
        'http://localhost/backend_project_rpl/select/get_limit_transaksi.php?id=$pengguna_id',
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

  Future<Map<String, dynamic>> getCombineData() async {
    final pengguna_id = await getPenggunaIdFromPrefs();
    if (pengguna_id == null) {
      throw Exception('ID tidak ditemukan');
    }

    final pengguna = await fetchPengguna(pengguna_id);
    final transaksi = await fetchTransaksi(pengguna_id);
    return {'pengguna': pengguna, 'transaksi': transaksi};
  }

  @override
  void initState() {
    super.initState();
    futurePengguna = getPenggunaIdFromPrefs().then((id) {
      if (id == null) throw Exception('ID tidak ditemukan');
      return fetchPengguna(id);
    });

    combineFuture = getCombineData();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: combineFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final pengguna = snapshot.data!['pengguna'] as Pengguna;
          final transaksiList = snapshot.data!['transaksi'] as List<Transaksi>;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xFF4C75FF),
              toolbarHeight: 65,
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            '${pengguna.username}',
                            style: TextStyle(
                              color: Color(0xFFF9FCFF),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Container(
                color: Color(0xFFFFFFFF),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Laporan Transaksi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Mei 2025',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xDD9BA3AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Card(
                          elevation: 2,
                          color: Color(0xFFFFFFFF),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 10,
                            ),
                            child: SizedBox(
                              height: 300,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  gridData: FlGridData(show: false),
                                  maxY: 30,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: Colors.grey[100],
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: bottomTitles,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 5,
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    makeGroupData(0, 8, 13),
                                    makeGroupData(1, 12, 15),
                                    makeGroupData(2, 16, 5),
                                    makeGroupData(3, 21, 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 16, bottom: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Riwayat Transaksi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      transaksiList.isEmpty
                          ? Text(
                            'Tidak ada transaksi',
                            style: TextStyle(fontSize: 22),
                          )
                          : Column(
                            children: [
                              ...transaksiList.take(6).map((trx) {
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
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF4C75FF),
                            fixedSize: Size(180, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFF9FCFF),
                            ),
                          ),
                        ),
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

  BarChartGroupData makeGroupData(int x, double y, double z) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color(0xFF1A1C4C),
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: z,
          color: Color(0xFF4C75FF),
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const periode = [
      'Minggu ke-1',
      'Minggu ke-2',
      'Minggu ke-3',
      'Minggu ke-4',
    ];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(periode[value.toInt()], style: const TextStyle(fontSize: 10)),
    );
  }
}
