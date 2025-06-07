import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheManager {
  static const String _prefixKpis = 'kpis_';
  static const String _prefixAvisos = 'avisos_';
  static const String _prefixHistorial = 'historial_';
  static const String _prefixUsuario = 'usuario_';
  static const String _suffixTimestamp = '_timestamp';
  
  // Duración del caché (en horas)
  static const int duracionCacheHoras = 2;
  
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }
  
  // Guardar datos en caché con timestamp
  static Future<void> _guardarConTimestamp(String key, String data) async {
    final prefs = await _getPrefs();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    await prefs.setString(key, data);
    await prefs.setInt(key + _suffixTimestamp, timestamp);
  }
  
  // Verificar si el caché está vigente
  static Future<bool> _esCacheValido(String key) async {
    final prefs = await _getPrefs();
    final timestamp = prefs.getInt(key + _suffixTimestamp);
    
    if (timestamp == null) return false;
    
    final fechaCache = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diferencia = DateTime.now().difference(fechaCache);
    
    return diferencia.inHours < duracionCacheHoras;
  }
  
  // Obtener datos del caché si están vigentes
  static Future<String?> _obtenerSiValido(String key) async {
    if (await _esCacheValido(key)) {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
    return null;
  }
  
  // === MÉTODOS PARA KPIs ===
  
  static Future<void> guardarKpis(String dni, Map<String, dynamic> kpis) async {
    final key = _prefixKpis + dni;
    final jsonString = jsonEncode(kpis);
    await _guardarConTimestamp(key, jsonString);
  }
  
  static Future<Map<String, dynamic>?> obtenerKpis(String dni) async {
    final key = _prefixKpis + dni;
    final jsonString = await _obtenerSiValido(key);
    
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        // Si hay error al decodificar, limpiamos el caché
        await limpiarKpis(dni);
      }
    }
    return null;
  }
  
  static Future<void> limpiarKpis(String dni) async {
    final prefs = await _getPrefs();
    final key = _prefixKpis + dni;
    await prefs.remove(key);
    await prefs.remove(key + _suffixTimestamp);
  }
  
  // === MÉTODOS PARA AVISOS ===
  
  static Future<void> guardarAvisos(String dni, List<dynamic> avisos) async {
    final key = _prefixAvisos + dni;
    final jsonString = jsonEncode(avisos);
    await _guardarConTimestamp(key, jsonString);
  }
  
  static Future<List<dynamic>?> obtenerAvisos(String dni) async {
    final key = _prefixAvisos + dni;
    final jsonString = await _obtenerSiValido(key);
    
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as List<dynamic>;
      } catch (e) {
        await limpiarAvisos(dni);
      }
    }
    return null;
  }
  
  static Future<void> limpiarAvisos(String dni) async {
    final prefs = await _getPrefs();
    final key = _prefixAvisos + dni;
    await prefs.remove(key);
    await prefs.remove(key + _suffixTimestamp);
  }
  
  // === MÉTODOS PARA HISTORIAL ===
  
  static Future<void> guardarHistorial(String dni, List<dynamic> historial) async {
    final key = _prefixHistorial + dni;
    final jsonString = jsonEncode(historial);
    await _guardarConTimestamp(key, jsonString);
  }
  
  static Future<List<dynamic>?> obtenerHistorial(String dni) async {
    final key = _prefixHistorial + dni;
    final jsonString = await _obtenerSiValido(key);
    
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as List<dynamic>;
      } catch (e) {
        await limpiarHistorial(dni);
      }
    }
    return null;
  }
  
  static Future<void> limpiarHistorial(String dni) async {
    final prefs = await _getPrefs();
    final key = _prefixHistorial + dni;
    await prefs.remove(key);
    await prefs.remove(key + _suffixTimestamp);
  }
  
  // === MÉTODOS PARA DATOS DE USUARIO ===
  
  static Future<void> guardarDatosUsuario(String dni, Map<String, dynamic> datos) async {
    final key = _prefixUsuario + dni;
    final jsonString = jsonEncode(datos);
    await _guardarConTimestamp(key, jsonString);
  }
  
  static Future<Map<String, dynamic>?> obtenerDatosUsuario(String dni) async {
    final key = _prefixUsuario + dni;
    final jsonString = await _obtenerSiValido(key);
    
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        await limpiarDatosUsuario(dni);
      }
    }
    return null;
  }
  
  static Future<void> limpiarDatosUsuario(String dni) async {
    final prefs = await _getPrefs();
    final key = _prefixUsuario + dni;
    await prefs.remove(key);
    await prefs.remove(key + _suffixTimestamp);
  }
  
  // === MÉTODOS GENERALES ===
  
  // Limpiar todo el caché de un usuario
  static Future<void> limpiarTodoCache(String dni) async {
    await Future.wait([
      limpiarKpis(dni),
      limpiarAvisos(dni),
      limpiarHistorial(dni),
      limpiarDatosUsuario(dni),
    ]);
  }
  
  // Limpiar todo el caché de la aplicación
  static Future<void> limpiarTodoElCache() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys();
    
    final keysToRemove = keys.where((key) => 
      key.startsWith(_prefixKpis) ||
      key.startsWith(_prefixAvisos) ||
      key.startsWith(_prefixHistorial) ||
      key.startsWith(_prefixUsuario)
    );
    
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
  
  // Verificar si existe caché para un usuario
  static Future<bool> existeCacheUsuario(String dni) async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys();
    
    return keys.any((key) => 
      key.startsWith(_prefixKpis + dni) ||
      key.startsWith(_prefixAvisos + dni) ||
      key.startsWith(_prefixHistorial + dni) ||
      key.startsWith(_prefixUsuario + dni)
    );
  }
  
  // Obtener información del caché
  static Future<Map<String, dynamic>> obtenerInfoCache(String dni) async {
    final prefs = await _getPrefs();
    
    final info = <String, dynamic>{};
    
    // Verificar cada tipo de caché
    final kpisTimestamp = prefs.getInt(_prefixKpis + dni + _suffixTimestamp);
    final avisosTimestamp = prefs.getInt(_prefixAvisos + dni + _suffixTimestamp);
    final historialTimestamp = prefs.getInt(_prefixHistorial + dni + _suffixTimestamp);
    final usuarioTimestamp = prefs.getInt(_prefixUsuario + dni + _suffixTimestamp);
    
    if (kpisTimestamp != null) {
      info['kpis'] = {
        'timestamp': kpisTimestamp,
        'fecha': DateTime.fromMillisecondsSinceEpoch(kpisTimestamp),
        'valido': await _esCacheValido(_prefixKpis + dni),
      };
    }
    
    if (avisosTimestamp != null) {
      info['avisos'] = {
        'timestamp': avisosTimestamp,
        'fecha': DateTime.fromMillisecondsSinceEpoch(avisosTimestamp),
        'valido': await _esCacheValido(_prefixAvisos + dni),
      };
    }
    
    if (historialTimestamp != null) {
      info['historial'] = {
        'timestamp': historialTimestamp,
        'fecha': DateTime.fromMillisecondsSinceEpoch(historialTimestamp),
        'valido': await _esCacheValido(_prefixHistorial + dni),
      };
    }
    
    if (usuarioTimestamp != null) {
      info['usuario'] = {
        'timestamp': usuarioTimestamp,
        'fecha': DateTime.fromMillisecondsSinceEpoch(usuarioTimestamp),
        'valido': await _esCacheValido(_prefixUsuario + dni),
      };
    }
    
    return info;
  }
}