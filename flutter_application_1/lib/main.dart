import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
// Este archivo define la URL base del backend Flask en Render
import 'config.dart';

void main() {
  runApp(AppChoferes());
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
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
    if (dni.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Por favor ingresá un DNI válido.';
      });
      return;
    }

    final url = Uri.parse('$baseUrl/api/login');

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresá tu DNI para continuar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Card de login
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _dniController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "DNI",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _login,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    "Ingresar",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final url = Uri.parse('$baseUrl/kpis/${widget.dni}');
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

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, ${widget.nombre}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (kpis != null)
              Text(
                kpis!['fecha'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchKPIs),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : kpis == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text("No se encontraron KPIs"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchKPIs,
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchKPIs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPIs Grid
                    Text(
                      "Métricas del día",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildKPICard(
                          "Entregas",
                          "${kpis!['entregas']}",
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                        _buildKPICard(
                          "Rechazos",
                          "${kpis!['rechazos']}",
                          Icons.cancel_outlined,
                          Colors.red,
                        ),
                        _buildKPICard(
                          "Puntualidad",
                          "${kpis!['puntualidad']}",
                          Icons.schedule,
                          Colors.blue,
                        ),
                        _buildKPICard(
                          "KM Recorridos",
                          "${kpis!['km']}",
                          Icons.route,
                          Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Nivel de servicio destacado
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Nivel de Servicio",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${kpis!['servicio']}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Acciones
                    Text(
                      "Acciones rápidas",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildActionButton(
                      "Ver Avisos",
                      Icons.notifications_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AvisosScreen(dni: widget.dni),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildActionButton(
                      "Historial de KPIs",
                      Icons.history,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistorialKpisScreen(dni: widget.dni),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildActionButton(
                      "Gráfico de Evolución",
                      Icons.analytics_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GraficoEvolucionScreen(dni: widget.dni),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AvisosScreen extends StatefulWidget {
  final String dni;

  const AvisosScreen({super.key, required this.dni});

  @override
  _AvisosScreenState createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  List<dynamic> avisos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvisos();
  }

  Future<void> _fetchAvisos() async {
    final url = Uri.parse('$baseUrl/avisos/${widget.dni}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        avisos = jsonDecode(response.body);
        _loading = false;
      });
    } else {
      setState(() {
        avisos = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avisos"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAvisos),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : avisos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No hay avisos recientes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchAvisos,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: avisos.length,
                itemBuilder: (context, index) {
                  final aviso = avisos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notification_important,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aviso['mensaje'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      aviso['fecha'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class HistorialKpisScreen extends StatefulWidget {
  final String dni;

  const HistorialKpisScreen({super.key, required this.dni});

  @override
  _HistorialKpisScreenState createState() => _HistorialKpisScreenState();
}

class _HistorialKpisScreenState extends State<HistorialKpisScreen> {
  List<dynamic> historial = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    final url = Uri.parse('$baseUrl/kpis/historial/${widget.dni}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        historial = jsonDecode(response.body);
        _loading = false;
      });
    } else {
      setState(() {
        historial = [];
        _loading = false;
      });
    }
  }

  Widget _buildKPIRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de KPIs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistorial,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No hay historial disponible",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHistorial,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  final kpi = historial[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                kpi['fecha'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildKPIRow(
                                      "Entregas",
                                      "${kpi['entregas']}",
                                      Icons.check_circle_outline,
                                      Colors.green,
                                    ),
                                    _buildKPIRow(
                                      "Rechazos",
                                      "${kpi['rechazos']}",
                                      Icons.cancel_outlined,
                                      Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildKPIRow(
                                      "Puntualidad",
                                      "${kpi['puntualidad']}",
                                      Icons.schedule,
                                      Colors.blue,
                                    ),
                                    _buildKPIRow(
                                      "KM",
                                      "${kpi['km']}",
                                      Icons.route,
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildKPIRow(
                            "Servicio",
                            "${kpi['servicio']}",
                            Icons.star,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
  String indicadorSeleccionado = 'puntualidad';
  final Map<String, Map<String, dynamic>> indicadores = {
    'puntualidad': {
      'label': 'Puntualidad',
      'icon': Icons.schedule,
      'color': Colors.blue,
    },
    'entregas': {
      'label': 'Entregas',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    'rechazos': {
      'label': 'Rechazos',
      'icon': Icons.cancel_outlined,
      'color': Colors.red,
    },
    'km': {'label': 'Kilómetros', 'icon': Icons.route, 'color': Colors.orange},
  };

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    final url = Uri.parse('$baseUrl/kpis/historial/${widget.dni}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        historial = jsonDecode(response.body);
        _loading = false;
      });
    } else {
      setState(() {
        historial = [];
        _loading = false;
      });
    }
  }

  double _getValue(dynamic kpi) {
    if (indicadorSeleccionado == 'puntualidad') {
      return double.parse(kpi[indicadorSeleccionado].replaceAll('%', ''));
    } else {
      return double.tryParse(kpi[indicadorSeleccionado].toString()) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicadorData = indicadores[indicadorSeleccionado]!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Evolución de ${indicadorData['label']}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistorial,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : historial.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No hay datos disponibles",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Selector de indicador
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Seleccionar indicador",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          children: indicadores.keys.map((key) {
                            final data = indicadores[key]!;
                            final isSelected = key == indicadorSeleccionado;

                            return FilterChip(
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    indicadorSeleccionado = key;
                                  });
                                }
                              },
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    data['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : data['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(data['label']),
                                ],
                              ),
                              backgroundColor: data['color'].withOpacity(0.1),
                              selectedColor: data['color'],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gráfico
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                indicadorData['icon'],
                                color: indicadorData['color'],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Evolución de ${indicadorData['label']}",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Expanded(
                            child: BarChart(
                              BarChartData(
                                backgroundColor: Colors.transparent,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval:
                                      indicadorSeleccionado == 'puntualidad'
                                      ? 10
                                      : null,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 &&
                                            index < historial.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              historial[index]['fecha']
                                                  .substring(5),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      interval: 1,
                                      reservedSize: 32,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval:
                                          indicadorSeleccionado == 'puntualidad'
                                          ? 20
                                          : null,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString() +
                                              (indicadorSeleccionado ==
                                                      'puntualidad'
                                                  ? '%'
                                                  : ''),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    left: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(historial.length, (i) {
                                  final value = _getValue(historial[i]);
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: value,
                                        color: indicadorData['color'],
                                        width: 16,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            indicadorData['color'].withOpacity(
                                              0.8,
                                            ),
                                            indicadorData['color'],
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                                    tooltipRoundedRadius: 8,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          if (groupIndex < historial.length) {
                                            final kpi = historial[groupIndex];
                                            return BarTooltipItem(
                                              '${kpi['fecha']}\n',
                                              TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onInverseSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${rod.toY.toStringAsFixed(indicadorSeleccionado == 'puntualidad' ? 1 : 0)}${indicadorSeleccionado == 'puntualidad' ? '%' : ''}',
                                                  style: TextStyle(
                                                    color:
                                                        indicadorData['color'],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return null;
                                        },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
