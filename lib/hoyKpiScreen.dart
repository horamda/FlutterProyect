import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class HoyKpiScreen extends StatefulWidget {
  final String dni;

  const HoyKpiScreen({super.key, required this.dni});

  @override
  _HoyKpiScreenState createState() => _HoyKpiScreenState();
}

class _HoyKpiScreenState extends State<HoyKpiScreen> {
  List<dynamic> _kpis = [];
  String _fecha = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchKpis();
  }

  Future<void> _fetchKpis() async {
    final url = Uri.parse('$baseUrl/kpis/hoy_o_ultimo/${widget.dni}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _kpis = json['kpis'];
          _fecha = json['fecha'];
          _loading = false;
        });
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando KPIs: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Indicadores'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _kpis.isEmpty
              ? const Center(child: Text('No hay KPIs disponibles.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _fecha == DateTime.now().toString().substring(0, 10)
                            ? '📊 KPIs de hoy'
                            : '📌 Últimos KPIs disponibles',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _kpis.length,
                        itemBuilder: (context, index) {
                          final kpi = _kpis[index];
                          return Card(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.bar_chart),
                              title: Text(kpi['indicador']),
                              subtitle: Text('Fecha: ${kpi['fecha']}'),
                              trailing: Text(
                                kpi['valor'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
