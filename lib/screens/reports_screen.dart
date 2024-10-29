import 'dart:developer';
import 'dart:io';

import 'package:fixio/cubit/fixio_cubit.dart';
import 'package:fixio/screens/home_screen.dart';
import 'package:fixio/screens/pdf_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

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
  bool _isLoading = false;
  int touchedGroupIndex = -1;
  late final Future<List<BarChartGroupData>> _showingBarGroups;

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
          toY: y1 >= 10000000 ? 10 : y1 / 1000000,
          color: Color(0xFFfe3175),
          width: 20,
        ),
        BarChartRodData(
          toY: y2 >= 10000000 ? 10 : y2 / 1000000,
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
    DateTime dateTime = DateTime.now();
    int day = 0;
    String dayOfWeek = DateFormat('EEEE').format(dateTime);
    switch (dayOfWeek) {
      case "Monday":
        day = 0;
        break;
      case "Tuesday":
        day = 1;
        break;
      case "Wednesday":
        day = 2;
        break;
      case "Thursday":
        day = 3;
        break;
      case "Friday":
        day = 4;
        break;
      case "Satuday":
        day = 5;
        break;
      case "Sunday":
        day = 6;
        break;
      default:
        day = 0;
    }

    // Initialiser une liste pour stocker les résultats
    List<BarChartGroupData> barChartData = [];

    List.generate(7, (i) {
      barChartData.addAll([makeGroupData(i, 0, 0)]);
    });

    // Parcourir la map et créer un BarChartGroupData pour chaque élément
    if (map.isEmpty) {
      print("Darrel");
      barChartData[day] = makeGroupData(day, 0, budget);
    }
    map.forEach((key, value) {
      print("$key - $value");
      barChartData[key] = makeGroupData(key, value, budget);
    });

    return barChartData;
  }

  Future<File> generatePDF(List<double> expenses) async {
    final pdf = pw.Document();

    final List<pw.TableRow> tableRows = <pw.TableRow>[
      pw.TableRow(
        children: [
          pw.Text('Budget',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Dépenses',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ];
    // Ajouter une ligne pour chaque dépense
    for (var expense in expenses) {
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Text(''), // Cellule vide pour "Budget"
            pw.Text(expense.toString(), style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // Ajouter une page avec du texte
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                pw.SizedBox(height: 40.h),
                pw.Text('Catalogue des depenses de l\'entreprise',
                    style: pw.TextStyle(fontSize: 32)),
                pw.SizedBox(height: 40.h),
                pw.Table(
                  border: pw.TableBorder.all(), // Bordures du tableau
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [...tableRows],
                )
              ]));
        },
      ),
    );

    // Récupère le répertoire temporaire pour stocker le PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/preview.pdf");

    // Sauvegarde le PDF dans le répertoire temporaire
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  void initState() {
    super.initState();

    _showingBarGroups = chatz(
        context.read<FixioCubit>().report(), context.read<FixioCubit>().state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports et graphiques'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Dépenses mensuelles',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Gap(70.h),
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
                  height: 420.h,
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
                      barTouchData: BarTouchData(
                        touchTooltipData:
                            BarTouchTooltipData(getTooltipColor: ((group) {
                          return Colors.grey;
                        }), getTooltipItem: (a, b, c, d) {
                          if (d == 1) {
                            return BarTooltipItem(
                              'Budget: ${c.toY * 1000000}\n', // Texte personnalisé
                              TextStyle(color: Colors.white),
                            );
                          }
                          if (d == 0) {
                            return BarTooltipItem(
                              'Depense: ${c.toY * 1000000}\n', // Texte personnalisé
                              TextStyle(color: Colors.white),
                            );
                          }
                        }),
                      ),
                      maxY: 10,
                    ),
                    swapAnimationDuration: Duration(milliseconds: 150),
                    swapAnimationCurve: Curves.linear,
                  ),
                );
              }),
          SizedBox(height: 30.h),
          ElevatedButton(
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Générer un rapport PDF'),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              final pdfFile = await generatePDF(
                  (await context.read<FixioCubit>().expense()).toList());
              setState(() {
                _isLoading = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfPreviewScreen(pdfFile: pdfFile),
                ),
              );
              // Logique pour générer et exporter un rapport PDF
            },
          ),
        ],
      ),
    );
  }
}
