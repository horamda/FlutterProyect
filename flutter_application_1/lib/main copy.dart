import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'config.dart';

void main() {
  runApp(const AppChoferes());
}

class AppChoferes extends StatelessWidget {
  const AppChoferes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Choferes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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
    if (dni.isEmpty || dni.length < 7 || !RegExp(r'^\d+$').hasMatch(dni)) {
      setState(() {
        _loading = false;
        _error = 'Por favor ingresá un DNI válido.';
      });
      return;
    }

    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'dni': dni}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(nombre: data['nombre'], dni: dni),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['message'] ?? 'Error desconocido.');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Chofer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "DNI",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Ingresar"),
                  ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String nombre;
  final String dni;

  const DashboardScreen({super.key, required this.nombre, required this.dni});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? kpis;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchKPIs();
  }

  Future<void> _fetchKPIs() async {
    final url = Uri.parse('$baseUrl/kpis/${widget.dni}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          kpis = jsonDecode(response.body);
          _error = null;
        });
      } else {
        setState(() => _error = 'Error al obtener KPIs.');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${widget.nombre}"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : kpis == null
          ? const Center(child: Text("No se encontraron KPIs"))
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AvisosScreen(dni: widget.dni),
                        ),
                      );
                    },
                    child: const Text("📋 Ver Avisos"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistorialKpisScreen(dni: widget.dni),
                        ),
                      );
                    },
                    child: const Text("📆 Historial de KPIs"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GraficoEvolucionScreen(dni: widget.dni),
                        ),
                      );
                    },
                    child: const Text("📊 Gráfico de KPIs"),
                  ),
                ],
              ),
            ),
    );
  }
}

class AvisosScreen extends StatefulWidget {
  final String dni;

  const AvisosScreen({super.key, required this.dni});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  List<dynamic> avisos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAvisos();
  }

  Future<void> _fetchAvisos() async {
    final url = Uri.parse('$baseUrl/avisos/${widget.dni}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          avisos = jsonDecode(response.body);
          _error = null;
        });
      } else {
        setState(() => _error = 'Error al cargar avisos.');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Avisos para el chofer")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : avisos.isEmpty
          ? const Center(child: Text("No hay avisos recientes"))
          : ListView.builder(
              itemCount: avisos.length,
              itemBuilder: (context, index) {
                final aviso = avisos[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.notification_important),
                    title: Text(aviso['mensaje']),
                    subtitle: Text("🕒 ${aviso['fecha']}"),
                  ),
                );
              },
            ),
    );
  }
}

class HistorialKpisScreen extends StatefulWidget {
  final String dni;

  const HistorialKpisScreen({super.key, required this.dni});

  @override
  State<HistorialKpisScreen> createState() => _HistorialKpisScreenState();
}

class _HistorialKpisScreenState extends State<HistorialKpisScreen> {
  List<dynamic> historial = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    final url = Uri.parse('$baseUrl/kpis/historial/${widget.dni}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          historial = jsonDecode(response.body);
          _error = null;
        });
      } else {
        setState(() => _error = 'Error al obtener historial.');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de KPIs")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : historial.isEmpty
          ? const Center(child: Text("No hay historial disponible"))
          : ListView.builder(
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final kpi = historial[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("📅 ${kpi['fecha']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✅ Entregas: ${kpi['entregas']}"),
                        Text("❌ Rechazos: ${kpi['rechazos']}"),
                        Text("🕒 Puntualidad: ${kpi['puntualidad']}"),
                        Text("📍 KM: ${kpi['km']}"),
                        Text("⭐ Servicio: ${kpi['servicio']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class GraficoEvolucionScreen extends StatefulWidget {
  final String dni;

  const GraficoEvolucionScreen({super.key, required this.dni});

  @override
  State<GraficoEvolucionScreen> createState() => _GraficoEvolucionScreenState();
}

class _GraficoEvolucionScreenState extends State<GraficoEvolucionScreen> {
  List<dynamic> historial = [];
  bool _loading = true;
  String? _error;
  String indicadorSeleccionado = 'puntualidad';

  final List<String> indicadores = [
    'puntualidad',
    'entregas',
    'rechazos',
    'km',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    final url = Uri.parse('$baseUrl/kpis/historial/${widget.dni}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          historial = jsonDecode(response.body);
          _error = null;
        });
      } else {
        setState(() => _error = 'Error al obtener historial.');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  double _getValue(dynamic kpi) {
    if (indicadorSeleccionado == 'puntualidad') {
      return double.tryParse(kpi[indicadorSeleccionado].replaceAll('%', '')) ??
          0;
    }
    return double.tryParse(kpi[indicadorSeleccionado].toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Evolución de ${indicadorSeleccionado.toUpperCase()}"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : historial.isEmpty
          ? const Center(child: Text("No hay datos disponibles"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: indicadorSeleccionado,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          indicadorSeleccionado = value;
                        });
                      }
                    },
                    items: indicadores.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < historial.length) {
                                  return Text(
                                    historial[index]['fecha'].substring(5),
                                  );
                                }
                                return const Text('');
                              },
                              interval: 1,
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                            ),
                          ),
                        ),
                        barGroups: List.generate(historial.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: _getValue(historial[i]),
                                color: Colors.blue,
                                width: 12,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
