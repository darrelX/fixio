import 'dart:developer';

import 'package:fixio/cubit/fixio_cubit.dart';
import 'package:fixio/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int touchedIndex = -1;

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Lundi';
        break;
      case 1:
        text = 'Mardi';
        break;
      case 2:
        text = 'Mercredi';
        break;
      case 3:
        text = 'Jeudi';
        break;
      case 4:
        text = 'Vendredi';
        break;
      case 5:
        text = 'Samedi';
        break;
      case 6:
        text = 'Dimance';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 5) {
      text = '5M';
    } else if (value == 10) {
      text = '10M';
    } else if (value == 15) {
      text = '15M';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Color(0xFFfe3175),
          width: 20,
        ),
        BarChartRodData(
          toY: y2,
          color: Color(0xFF00fdce),
          width: 20,
        ),
      ],
    );
  }

  // Fonction pour transformer la map en une liste de BarChartGroupData
  Future<List<BarChartGroupData>> chatz(
      Future<Map<int, double>> futureMap, double budget) async {
    // Attendre que le Future Map soit résolu
    final map = await futureMap;

    // Initialiser une liste pour stocker les résultats
    List<BarChartGroupData> barChartData = [];

    List.generate(7, (i) {
      barChartData.addAll([makeGroupData(i, 0, 0)]);
    });

    // Parcourir la map et créer un BarChartGroupData pour chaque élément
    map.forEach((key, value) {
      print("$key - $value");
      // Ajouter le résultat à la liste
      barChartData[key] = makeGroupData(key, value / 10000, budget / 100000);
      // barChartData.add(makeGroupData(
      //     key,
      //     value / 10000,
      //     budget /
      //         100000)); // Utiliser une valeur fixe (10) pour le deuxième paramètre, ou ajuster en conséquence
    });

    // Retourner la liste des BarChartGroupData
    return barChartData;
  }

  late final Future<List<BarChartGroupData>> _showingBarGroups;

  @override
  void initState() {
    super.initState();

    _showingBarGroups = chatz(
        context.read<FixioCubit>().report(), context.read<FixioCubit>().state);
    // _showingBarGroups.addAll([
    //   makeGroupData(0, 12, 2),
    //   makeGroupData(0, 40, 2),
    //   makeGroupData(0, 5, 2),
    //   makeGroupData(0, 5, 2),
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports et graphiques'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Dépenses mensuelles',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Gap(120.h),
            FutureBuilder(
                future: _showingBarGroups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun équipement trouvé'));
                  }
                  return Container(
                    height: 400.h,
                    child: BarChart(
                      BarChartData(
                        barGroups: snapshot.data,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40.r,
                                getTitlesWidget: _leftTitles),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28.r,
                                getTitlesWidget: _bottomTitles),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        maxY: 10,
                      ),
                      swapAnimationDuration: Duration(milliseconds: 150),
                      swapAnimationCurve: Curves.linear,
                    ),
                  );
                }),
            // Container(
            //   height: 300,
            //   padding: const EdgeInsets.all(16),
            //   child: BarChart(
            //     swapAnimationDuration: Duration(milliseconds: 150), // Optional
            //     swapAnimationCurve: Curves.linear,
            //     // BarTouchTooltipData()
            //   ),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Générer un rapport PDF'),
              onPressed: () {
                // Logique pour générer et exporter un rapport PDF
              },
            ),
          ],
        ),
      ),
    );
  }
}
