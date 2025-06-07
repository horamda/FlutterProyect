import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class AvisosScreen extends StatefulWidget {
  final String dni;

  const AvisosScreen({super.key, required this.dni});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  List<dynamic> avisos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAvisos();
  }

  Future<void> fetchAvisos() async {
    final url = Uri.parse('$baseUrl/avisos/${widget.dni}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          avisos = data;
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

  Widget _buildAvisoCard(Map<String, dynamic> aviso) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.campaign, color: Colors.blue),
        title: Text(aviso['mensaje']),
        subtitle: Text("📅 ${aviso['fecha']}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avisos')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : avisos.isEmpty
              ? const Center(child: Text("No hay avisos disponibles."))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: avisos.length,
                  itemBuilder: (context, index) {
                    return _buildAvisoCard(avisos[index]);
                  },
                ),
    );
  }
}
