import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'config.dart';

class GraficoKPIScreen extends StatefulWidget {
  final String dni;
  final String indicador;

  const GraficoKPIScreen({
    super.key,
    required this.dni,
    required this.indicador,
  });

  @override
  State<GraficoKPIScreen> createState() => _GraficoKPIScreenState();
}

class _GraficoKPIScreenState extends State<GraficoKPIScreen> {
  List<String> fechas = [];
  List<double> valores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorial();
  }

  Future<void> fetchHistorial() async {
    final url = Uri.parse("$baseUrl/kpis/historial/${widget.dni}");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        final fechasTmp = <String>[];
        final valoresTmp = <double>[];

        for (var item in data) {
          if (item.containsKey(widget.indicador)) {
            fechasTmp.add(item['fecha']);
            valoresTmp.add((item[widget.indicador] as num).toDouble());
          }
        }

        setState(() {
          fechas = fechasTmp.reversed.toList();
          valores = valoresTmp.reversed.toList();
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📈 Evolución: ${widget.indicador}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : valores.isEmpty
          ? const Center(child: Text("No hay datos para este indicador."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(valores.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: valores[i], width: 16)],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          return i >= 0 && i < fechas.length
                              ? Text(
                                  fechas[i].substring(5),
                                  style: const TextStyle(fontSize: 10),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
    );
  }
}
