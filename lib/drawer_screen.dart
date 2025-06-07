import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'avisos_screen.dart';
import 'historial_screen.dart';
import 'grafico_kpis_screen.dart';
import 'login_screen.dart';
import 'config.dart';

class DrawerScreen extends StatefulWidget {
  final String nombre;
  final String sector;
  final String dni;

  const DrawerScreen({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
  });

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        nombre: widget.nombre,
        sector: widget.sector,
        dni: widget.dni,
      ),
      AvisosScreen(dni: widget.dni),
      HistorialScreen(dni: widget.dni),
      GraficoKPIScreen(dni: widget.dni, indicador: 'puntualidad'), // o cualquier valor por defecto
    ];

    final List<String> titles = [
      'Panel de Indicadores',
      'Avisos',
      'Historial de KPIs',
      'Gráfico de Evolución',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                   backgroundImage: NetworkImage(
  '$baseUrl/imagen/${widget.dni}',
),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    widget.sector,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () => _navigateTo(0),
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Avisos'),
              selected: _selectedIndex == 1,
              onTap: () => _navigateTo(1),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial KPIs'),
              selected: _selectedIndex == 2,
              onTap: () => _navigateTo(2),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Gráfico de Evolución'),
              selected: _selectedIndex == 3,
              onTap: () => _navigateTo(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex],
    );
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }
}
