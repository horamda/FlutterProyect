import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class HistorialScreen extends StatefulWidget {
  final String dni;

  const HistorialScreen({super.key, required this.dni});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> historial = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorial();
  }

  Future<void> fetchHistorial() async {
    final url = Uri.parse("$baseUrl/kpis/hoy_o_ultimo/${widget.dni}");
    

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          historial = data;
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

  Widget _buildFechaCard(Map<String, dynamic> kpisPorFecha) {
    final fecha = kpisPorFecha['fecha'];
    final indicadores = Map<String, dynamic>.from(kpisPorFecha)
      ..remove('fecha');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(
          "📅 $fecha",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: indicadores.entries.map((entry) {
          return ListTile(
            title: Text(entry.key.toUpperCase()),
            trailing: Text(entry.value.toString()),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de KPIs')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
          ? const Center(child: Text("No hay historial disponible."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: historial.map((e) => _buildFechaCard(e)).toList(),
            ),
    );
  }
}
