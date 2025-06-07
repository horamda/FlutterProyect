import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'drawer_screen.dart';

void main() {
  runApp(const AppPersonal());
}

class AppPersonal extends StatelessWidget {
  const AppPersonal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Empleados',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      // Comienza en la pantalla de carga
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/drawer': (context) =>
            const Placeholder(), // se reemplaza en tiempo de ejecución
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/drawer') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => DrawerScreen(
              nombre: args['nombre'],
              sector: args['sector'],
              dni: args['dni'],
            ),
          );
        }
        return null;
      },
    );
  }
}
