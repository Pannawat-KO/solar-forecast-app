import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Forecast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          surface: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    SolarChartPage(),
    QualityScorecardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Data Quality',
          ),
        ],
      ),
    );
  }
}

// ===================== FORECAST PAGE =====================

class SolarChartPage extends StatefulWidget {
  const SolarChartPage({super.key});

  @override
  State<SolarChartPage> createState() => _SolarChartPageState();
}

class _SolarChartPageState extends State<SolarChartPage> {
  List<dynamic> solarData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final String response =
        await rootBundle.loadString('assets/solar_forecast.json');
    final data = json.decode(response);
    setState(() {
      solarData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solar Power Forecast - Bangkok')),
      body: solarData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: solarData.asMap().entries.map((entry) {
                    int index = entry.key;
                    var month = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: month['ac_power_kwh'],
                          color: Colors.orange,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < solarData.length) {
                            return Text(solarData[index]['month']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ===================== QUALITY SCORECARD PAGE =====================

class QualityScorecardPage extends StatefulWidget {
  const QualityScorecardPage({super.key});

  @override
  State<QualityScorecardPage> createState() => _QualityScorecardPageState();
}

class _QualityScorecardPageState extends State<QualityScorecardPage> {
  List<dynamic> qualityData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final String response =
        await rootBundle.loadString('assets/quality_log.json');
    final data = json.decode(response);
    setState(() {
      qualityData = data;
    });
  }

  Color gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Quality Scorecard')),
      body: qualityData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.round();
                                if (index != value) return const Text('');
                                if (index >= 0 && index < qualityData.length) {
                                  String date = qualityData[index]['date'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      date.substring(5),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: qualityData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var day = entry.value;
                              return FlSpot(index.toDouble(), day['score']);
                            }).toList(),
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: qualityData.length,
                    itemBuilder: (context, index) {
                      final day = qualityData[qualityData.length - 1 - index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: gradeColor(day['grade']),
                          child: Text(
                            day['grade'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(day['date']),
                        subtitle: Text(
                            '${day['valid_count']}/${day['total_count']} records passed'),
                        trailing: Text('${day['score']}%'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}