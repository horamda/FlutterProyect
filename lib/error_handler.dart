import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'constants.dart';

// Mixin para manejo mejorado de errores de API
mixin ManejadorErroresApi {
  String manejarErrorApi(dynamic error) {
    if (error is SocketException) {
      return AppConstants.errorSinInternet;
    } else if (error is TimeoutException) {
      return AppConstants.errorTimeout;
    } else if (error is FormatException) {
      return AppConstants.errorDatos;
    } else if (error is http.ClientException) {
      return AppConstants.errorConexion;
    } else {
      return AppConstants.errorGeneral;
    }
  }
  
  void mostrarSnackBar(BuildContext context, String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Widget de carga personalizado
class WidgetCargaPersonalizada extends StatelessWidget {
  final String mensaje;
  final Color? color;
  
  const WidgetCargaPersonalizada({
    super.key, 
    this.mensaje = AppConstants.cargandoGeneral,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget de carga compacto para usar en cards
class WidgetCargaCompacta extends StatelessWidget {
  final String? mensaje;
  
  const WidgetCargaCompacta({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (mensaje != null) ...[
            const SizedBox(width: 12),
            Text(
              mensaje!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// Widget de error personalizado
class WidgetErrorPersonalizado extends StatelessWidget {
  final String mensaje;
  final VoidCallback? alReintentar;
  final IconData? icono;
  final String? textoBoton;
  
  const WidgetErrorPersonalizado({
    super.key,
    required this.mensaje,
    this.alReintentar,
    this.icono,
    this.textoBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono ?? Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (alReintentar != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh),
                label: Text(textoBoton ?? AppConstants.reintentar),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar cuando no hay datos
class WidgetSinDatos extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final VoidCallback? alReintentar;
  
  const WidgetSinDatos({
    super.key,
    required this.mensaje,
    required this.icono,
    this.alReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (alReintentar != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text(AppConstants.actualizar),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Estados de la aplicación
enum EstadoApp {
  inicial,
  cargando,
  exitoso,
  error,
  sinDatos,
}

// Clase para manejar el estado de las pantallas
class EstadoPantalla {
  final EstadoApp estado;
  final String? mensaje;
  final dynamic datos;
  
  const EstadoPantalla({
    required this.estado,
    this.mensaje,
    this.datos,
  });
  
  factory EstadoPantalla.inicial() {
    return const EstadoPantalla(estado: EstadoApp.inicial);
  }
  
  factory EstadoPantalla.cargando([String? mensaje]) {
    return EstadoPantalla(
      estado: EstadoApp.cargando,
      mensaje: mensaje,
    );
  }
  
  factory EstadoPantalla.exitoso(dynamic datos) {
    return EstadoPantalla(
      estado: EstadoApp.exitoso,
      datos: datos,
    );
  }
  
  factory EstadoPantalla.error(String mensaje) {
    return EstadoPantalla(
      estado: EstadoApp.error,
      mensaje: mensaje,
    );
  }
  
  factory EstadoPantalla.sinDatos([String? mensaje]) {
    return EstadoPantalla(
      estado: EstadoApp.sinDatos,
      mensaje: mensaje,
    );
  }
}

// Widget builder para manejar estados
class ConstructorEstado extends StatelessWidget {
  final EstadoPantalla estado;
  final Widget Function(dynamic datos) builderExitoso;
  final Widget Function()? builderInicial;
  final String? mensajeCarga;
  final String? mensajeSinDatos;
  final IconData? iconoSinDatos;
  final VoidCallback? alReintentar;
  
  const ConstructorEstado({
    super.key,
    required this.estado,
    required this.builderExitoso,
    this.builderInicial,
    this.mensajeCarga,
    this.mensajeSinDatos,
    this.iconoSinDatos,
    this.alReintentar,
  });

  @override
  Widget build(BuildContext context) {
    switch (estado.estado) {
      case EstadoApp.inicial:
        return builderInicial?.call() ?? 
               const WidgetCargaPersonalizada();
               
      case EstadoApp.cargando:
        return WidgetCargaPersonalizada(
          mensaje: mensajeCarga ?? estado.mensaje ?? AppConstants.cargandoGeneral,
        );
        
      case EstadoApp.exitoso:
        return builderExitoso(estado.datos);
        
      case EstadoApp.error:
        return WidgetErrorPersonalizado(
          mensaje: estado.mensaje ?? AppConstants.errorGeneral,
          alReintentar: alReintentar,
        );
        
      case EstadoApp.sinDatos:
        return WidgetSinDatos(
          mensaje: mensajeSinDatos ?? estado.mensaje ?? AppConstants.sinDatos,
          icono: iconoSinDatos ?? Icons.inbox_outlined,
          alReintentar: alReintentar,
        );
    }
  }
}