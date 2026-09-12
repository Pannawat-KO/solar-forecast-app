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
    return MaterialApp(title: 'Solar Forecast',debugShowCheckedModeBanner: false, home: const SolarChartPage());
  }
}

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
    final String response = await rootBundle.loadString(
      'assets/solar_forecast.json',
    );
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
