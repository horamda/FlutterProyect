class AppConstants {
  // Información de la app
  static const String appName = 'App Empleados';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Mensajes de error
  static const String errorConexion = 'Error de conexión con el servidor';
  static const String errorSinInternet = 'Sin conexión a internet';
  static const String errorTimeout = 'Tiempo de espera agotado';
  static const String errorDatos = 'Error en el formato de datos';
  static const String errorGeneral = 'Ha ocurrido un error inesperado';
  static const String errorDniInvalido = 'DNI no válido o no encontrado';
  
  // Mensajes informativos
  static const String sinDatos = 'No hay datos disponibles';
  static const String sinAvisos = 'No hay avisos disponibles';
  static const String sinKpis = 'No hay KPIs disponibles';
  static const String sinHistorial = 'No hay historial disponible';
  
  // Mensajes de carga
  static const String cargandoGeneral = 'Cargando...';
  static const String cargandoKpis = 'Cargando KPIs...';
  static const String cargandoAvisos = 'Cargando avisos...';
  static const String cargandoHistorial = 'Cargando historial...';
  static const String cargandoGrafico = 'Cargando gráfico...';
  static const String validandoCredenciales = 'Validando credenciales...';
  
  // Botones y acciones
  static const String reintentar = 'Reintentar';
  static const String actualizar = 'Actualizar';
  static const String cerrar = 'Cerrar';
  static const String ingresar = 'Ingresar';
  static const String cerrarSesion = 'Cerrar sesión';
  
  // Títulos de pantallas
  static const String tituloDashboard = 'Panel de Indicadores';
  static const String tituloAvisos = 'Avisos';
  static const String tituloHistorial = 'Historial de KPIs';
  static const String tituloGrafico = 'Gráfico de Evolución';
  static const String tituloLogin = 'Ingreso';
  
  // Validaciones
  static const int dniMinLength = 7;
  static const int dniMaxLength = 8;
  static const String dniPattern = r'^\d+$';
  
  // Colores personalizados (opcional)
  static const Map<String, int> coloresPersonalizados = {
    'primaryColor': 0xFF3F51B5,
    'accentColor': 0xFF2196F3,
    'errorColor': 0xFFF44336,
    'successColor': 0xFF4CAF50,
    'warningColor': 0xFFFF9800,
  };
  
  // Tipos de avisos
  static const String tipoAvisoUrgente = 'urgente';
  static const String tipoAvisoInfo = 'info';
  static const String tipoAvisoRecordatorio = 'recordatorio';
  
  // Endpoints (para centralizar las rutas de API)
  static const String endpointLogin = '/api/login';
  static const String endpointAvisos = '/avisos';
  static const String endpointKpisHoy = '/kpis/hoy_o_ultimo';
  static const String endpointKpisHistorial = '/kpis/historial';
  static const String endpointImagenChofer = '/chofer/imagen';
}

// Utilidades para validaciones
class Validadores {
  static bool validarDNI(String dni) {
    if (dni.isEmpty) return false;
    if (dni.length < AppConstants.dniMinLength || 
        dni.length > AppConstants.dniMaxLength) return false;
    return RegExp(AppConstants.dniPattern).hasMatch(dni);
  }
  
  static String? validarDNIConMensaje(String dni) {
    if (dni.isEmpty) {
      return 'El DNI es requerido';
    }
    if (dni.length < AppConstants.dniMinLength) {
      return 'El DNI debe tener al menos ${AppConstants.dniMinLength} dígitos';
    }
    if (dni.length > AppConstants.dniMaxLength) {
      return 'El DNI no puede tener más de ${AppConstants.dniMaxLength} dígitos';
    }
    if (!RegExp(AppConstants.dniPattern).hasMatch(dni)) {
      return 'El DNI solo puede contener números';
    }
    return null;
  }
}

// Utilidades para URLs
class UrlHelper {
  static String getImagenChoferUrl(String baseUrl, String dni) {
    return '$baseUrl${AppConstants.endpointImagenChofer}/$dni';
  }
  
  static String getAvisosUrl(String baseUrl, String dni) {
    return '$baseUrl${AppConstants.endpointAvisos}/$dni';
  }
  
  static String getKpisHoyUrl(String baseUrl, String dni) {
    return '$baseUrl${AppConstants.endpointKpisHoy}/$dni';
  }
  
  static String getKpisHistorialUrl(String baseUrl, String dni) {
    return '$baseUrl${AppConstants.endpointKpisHistorial}/$dni';
  }
}