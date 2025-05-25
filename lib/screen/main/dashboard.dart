import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:project_rpl/screen/main/history.dart';

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
  final bool? limit;

  Transaksi({
    this.judul_transaksi,
    this.keterangan,
    this.nominal,
    this.tanggal,
    this.jenis_transaksi,
    this.limit,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      judul_transaksi: json['judul_transaksi'],
      keterangan: json['keterangan'],
      nominal: json['nominal'],
      tanggal: json['tanggal'],
      jenis_transaksi: json['jenis_transaksi'],
      limit: true,
    );
  }
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  DashboardWidgetState createState() => DashboardWidgetState();
}

class DashboardWidgetState extends State<DashboardWidget> {
  late Future<Pengguna> futurePengguna;
  late Future<Map<String, dynamic>> combineFuture;
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
        'http://10.0.2.2/backend_project_rpl/select/get_transaksi.php?id=$pengguna_id&limit=true',
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

  Future<Map<String, dynamic>> loadData() async {
    final pengguna_id = await getPenggunaIdFromPrefs();
    if (pengguna_id == null) throw Exception('ID tidak ditemukan');
    final pengguna = await fetchPengguna(pengguna_id);
    final transaksi = await fetchTransaksi(pengguna_id);
    return {'pengguna': pengguna, 'transaksi': transaksi};
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

  List<BarChartGroupData> generateBarChartData(List<Transaksi> transaksiList) {
    final Map<int, Map<String, double>> mingguData = {
      0: {'pemasukan': 0, 'pengeluaran': 0},
      1: {'pemasukan': 0, 'pengeluaran': 0},
      2: {'pemasukan': 0, 'pengeluaran': 0},
      3: {'pemasukan': 0, 'pengeluaran': 0},
    };

    for (var trx in transaksiList) {
      if (trx.tanggal != null &&
          trx.nominal != null &&
          trx.jenis_transaksi != null) {
        DateTime tanggal = DateTime.parse(trx.tanggal!);
        int minggu = ((tanggal.day - 1) / 7).floor().clamp(0, 3);

        if (trx.jenis_transaksi == 'pemasukan') {
          mingguData[minggu]!['pemasukan'] =
              mingguData[minggu]!['pemasukan']! + trx.nominal!;
        } else if (trx.jenis_transaksi == 'pengeluaran') {
          mingguData[minggu]!['pengeluaran'] =
              mingguData[minggu]!['pengeluaran']! + trx.nominal!;
        }
      }
    }

    return List.generate(4, (index) {
      final pemasukan = mingguData[index]!['pemasukan'] ?? 0;
      final pengeluaran = mingguData[index]!['pengeluaran'] ?? 0;
      return makeGroupData(index, pemasukan, pengeluaran);
    });
  }

  double getMaxY(List<Transaksi> transaksiList) {
    double maxNominal = 0;
    final Map<int, double> mingguanPemasukan = {0: 0, 1: 0, 2: 0, 3: 0};
    final Map<int, double> mingguanPengeluaran = {0: 0, 1: 0, 2: 0, 3: 0};
    for (var trx in transaksiList) {
      if (trx.nominal != null && trx.tanggal != null) {
        final minggu = ((DateTime.parse(trx.tanggal!).day - 1) / 7)
            .floor()
            .clamp(0, 3);
        if (trx.jenis_transaksi == 'pemasukan') {
          mingguanPemasukan[minggu] = mingguanPemasukan[minggu]! + trx.nominal!;
        } else {
          mingguanPengeluaran[minggu] =
              mingguanPengeluaran[minggu]! + trx.nominal!;
        }
      }
    }

    for (int i = 0; i < 4; i++) {
      final tertinggi =
          (mingguanPemasukan[i]! > mingguanPengeluaran[i]!)
              ? mingguanPemasukan[i]!
              : mingguanPengeluaran[i]!;

      if (tertinggi > maxNominal) {
        maxNominal = tertinggi;
      }
    }

    return (maxNominal).ceilToDouble() + 5;
  }

  String formatRupiah(num data) {
    if (data >= 10000000) {
      return '${(data / 1000000).toStringAsFixed(1)}M';
    } else if (data >= 1000000) {
      return '${(data / 1000000).toStringAsFixed(1)}jt';
    } else if (data >= 100000) {
      return '${(data / 1000).toStringAsFixed(1)}K';
    } else if (data >= 10000) {
      return '${(data / 1000).toStringAsFixed(1)}K';
    } else {
      return data.toString();
    }
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

  void refreshDashboard() {
    setState(() {
      combineFuture = getCombineData();
    });
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
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
                            image: DecorationImage(
                              image: AssetImage('assets/images/profile.jpeg'),
                              fit: BoxFit.cover,
                            ),
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
            body:
                transaksiList.isEmpty
                    ? Center(
                      child: Text(
                        'Tidak ada transaksi',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : Padding(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Laporan Transaksi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('MMMM yyyy').format(DateTime.now())}',
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
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Card(
                                  elevation: 2,
                                  color: Color(0xFFFFFFFF),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 32,
                                      bottom: 15,
                                    ),
                                    child: SizedBox(
                                      height: 300,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          gridData: FlGridData(show: false),
                                          maxY: getMaxY(transaksiList),
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                                  tooltipBgColor:
                                                      Colors.grey[100],
                                                  getTooltipItem: (
                                                    group,
                                                    groupIndex,
                                                    rod,
                                                    rodIndex,
                                                  ) {
                                                    final value = rod.toY;
                                                    return BarTooltipItem(
                                                      formatRupiah(value),
                                                      TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    );
                                                  },
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
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    formatRupiah(value),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: generateBarChartData(
                                            transaksiList,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  top: 16,
                                  bottom: 5,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Riwayat Transaksi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  ...transaksiList.take(6).map((trx) {
                                    final formattedTanggal = DateFormat(
                                      'dd MMM yyyy HH:mm',
                                    ).format(DateTime.parse(trx.tanggal ?? ''));
                                    final formattedNominal =
                                        NumberFormat.currency(
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => HistoryWidget(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(0xFF4C75FF),
                                        fixedSize: Size(180, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
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
