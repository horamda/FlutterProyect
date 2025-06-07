import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'grafico_kpis_screen.dart'; // Asegurate de tener esta pantalla creada

class DashboardScreen extends StatefulWidget {
  final String nombre;
  final String sector;
  final String dni;

  const DashboardScreen({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> kpis = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchKPIs();
  }

  Future<void> fetchKPIs() async {
    final url = Uri.parse('$baseUrl/kpis/hoy_o_ultimo/${widget.dni}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          kpis = data;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildKpiCard(String indicador, dynamic valor) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(
          indicador.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(valor.toString(), style: const TextStyle(fontSize: 18)),
        onTap: () {
          // Navegar a pantalla de gráfico
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GraficoKPIScreen(
                dni: widget.dni,
                indicador: indicador,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = '$baseUrl/chofer/imagen/${widget.dni}';

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Indicadores')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 30,
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "📌 ${widget.sector}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (kpis['fecha'] != null)
                            Text(
                              "📅 ${kpis['fecha']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (kpis['kpis'] != null)
                    Text(
                      kpis['fecha'] == DateTime.now().toString().substring(0, 10)
                          ? '📊 KPIs de hoy'
                          : '📌 Últimos KPIs disponibles',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Lista de KPIs
                  Expanded(
                    child: kpis['kpis'] != null && kpis['kpis'].isNotEmpty
                        ? ListView.builder(
                            itemCount: kpis['kpis'].length,
                            itemBuilder: (context, index) {
                              final item = kpis['kpis'][index];
                              return _buildKpiCard(
                                  item['indicador'], item['valor']);
                            },
                          )
                        : const Center(
                            child: Text("No hay KPIs cargados para hoy."),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
