import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AppChoferes());
}

class AppChoferes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Choferes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _dniController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final dni = _dniController.text.trim();
    final url = Uri.parse('http://localhost:5000/login'); // ⚠️ CAMBIAR por IP real en producción

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'dni': dni}),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(nombre: data['nombre'], dni: dni),
        ),
      );
    } else {
      final data = jsonDecode(response.body);
      setState(() => _error = data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Chofer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "DNI",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text("Ingresar")),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String nombre;
  final String dni;

  DashboardScreen({required this.nombre, required this.dni});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? kpis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchKPIs();
  }

  Future<void> _fetchKPIs() async {
    final url = Uri.parse('http://localhost:5000/kpis/${widget.dni}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        kpis = jsonDecode(response.body);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        kpis = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido, ${widget.nombre}")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : kpis == null
              ? Center(child: Text("No se encontraron KPIs"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📅 Fecha: ${kpis!['fecha']}"),
                      Text("✅ Entregas: ${kpis!['entregas']}"),
                      Text("❌ Rechazos: ${kpis!['rechazos']}"),
                      Text("🕒 Puntualidad: ${kpis!['puntualidad']}"),
                      Text("📍 KM recorridos: ${kpis!['km']}"),
                      Text("⭐ Nivel de servicio: ${kpis!['servicio']}"),
                    ],
                  ),
                ),
    );
  }
}
