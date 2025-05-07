import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class homeWidget extends StatefulWidget {
  const homeWidget({super.key});

  @override
  State<homeWidget> createState() => _homeWidgetState();
}

class _homeWidgetState extends State<homeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Color(0xFF4C75FF),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FCFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            color: Color(0xFFF9FCFF),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Alexander Von Hoffman',
                          style: TextStyle(
                            color: Color(0xFFF9FCFF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Container(
          color: Color(0xFFFFFFFF),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Text(
                    textAlign: TextAlign.left,
                    'Mei 2025',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Card(
                  elevation: 2,
                  color: Color(0xFFF9FCFF),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                            makeGroupData(4, 29, 29),
                            makeGroupData(5, 8, 1),
                            makeGroupData(6, 12, 20),
                            makeGroupData(7, 16, 9),
                            makeGroupData(8, 21, 30),
                            makeGroupData(9, 29, 6),
                            makeGroupData(10, 21, 30),
                            makeGroupData(11, 29, 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: 35,
                    decoration: BoxDecoration(color: Color(0xFFBEDAFF)),
                    child: Text(
                      textAlign: TextAlign.center,
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                for (int i = 0; i < 7; i++)
                  Card(
                    color: Color(0xFFF9FCFF),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF4C75FF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.horizontal_rule,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      title: Text(
                        'Bayar Uang Kas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Uang kas 01 Mei 2025 11:00 WIB',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        'Rp 217.000',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF4C75FF),
                      fixedSize: Size(200, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  BarChartGroupData makeGroupData(int x, double y, double z) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color(0xFF1A1C4C),
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: z,
          color: Color(0xFF4C75FF),
          width: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const periode = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Okt',
      'Nov',
      'Dec',
    ];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(periode[value.toInt()], style: const TextStyle(fontSize: 12)),
    );
  }
}
