import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'drawer_screen.dart';
import 'constants.dart';
import 'error_handler.dart';
import 'cache_manager.dart';

class LoginScreenMejorada extends StatefulWidget {
  const LoginScreenMejorada({super.key});
  
  @override
  State<LoginScreenMejorada> createState() => _LoginScreenMejoradaState();
}

class _LoginScreenMejoradaState extends State<LoginScreenMejorada> 
    with ManejadorErroresApi, TickerProviderStateMixin {
  final TextEditingController _dniController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _dniFocusNode = FocusNode();
  
  bool _cargando = false;
  String? _mensajeError;
  bool _mostrarContrasena = false; // Por si en el futuro se agrega contraseña
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _verificarCredencialesGuardadas();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _dniController.dispose();
    _dniFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Verificar si hay credenciales guardadas
  Future<void> _verificarCredencialesGuardadas() async {
    try {
      // Verificar si hay datos de usuario en caché
      final datosUsuario = await CacheManager.obtenerDatosUsuario();
      if (datosUsuario != null && datosUsuario['dni'] != null) {
        // Auto-rellenar el DNI si está guardado
        _dniController.text = datosUsuario['dni'];
      }
    } catch (e) {
      // Silently handle cache errors
    }
    
    // Aquí podrías implementar auto-login si tienes las credenciales guardadas
    // Por ahora solo enfocamos el campo DNI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dniFocusNode.requestFocus();
    });
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _cargando = true;
      _mensajeError = null;
    });
    
    final dni = _dniController.text.trim();
    final url = Uri.parse('$baseUrl${AppConstants.endpointLogin}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'dni': dni}),
      ).timeout(AppConstants.timeoutDuration);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar datos del usuario en caché
        await CacheManager.guardarDatosUsuario(dni, {
          'nombre': data['nombre'],
          'sector': data['sector'],
          'dni': dni,
          'fechaLogin': DateTime.now().toIso8601String(),
        });
        
        if (mounted) {
          // Haptic feedback para éxito
          HapticFeedback.lightImpact();
          
          // Navegación exitosa con animación
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DrawerScreen(
                nombre: data['nombre'],
                sector: data['sector'],
                dni: dni,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        // Haptic feedback para error
        HapticFeedback.mediumImpact();
        setState(() {
          _mensajeError = AppConstants.errorDniInvalido;
        });
        // Limpiar el campo para que el usuario pueda reintentar
        _dniController.clear();
        _dniFocusNode.requestFocus();
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _mensajeError = 'Error del servidor (${response.statusCode})';
        });
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _mensajeError = manejarErrorApi(e);
      });
    }
    
    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }
  
  void _limpiarFormulario() {
    _dniController.clear();
    setState(() {
      _mensajeError = null;
    });
    _dniFocusNode.requestFocus();
  }
  
  String? _validarDni(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su DNI';
    }
    
    // Remover espacios y caracteres especiales
    final dniLimpio = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (dniLimpio.length < 7 || dniLimpio.length > 8) {
      return 'El DNI debe tener entre 7 y 8 dígitos';
    }
    
    if (!RegExp(r'^\d+
      ).hasMatch(dniLimpio)) {
      return 'El DNI solo debe contener números';
    }
    
    return null;
  }
  
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar Sesión',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _dniController,
              focusNode: _dniFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              validator: _validarDni,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'DNI',
                hintText: 'Ingrese su DNI',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            if (_mensajeError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mensajeError!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargando ? null : _limpiarFormulario,
              child: Text(
                'Limpiar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top - 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildLogo(),
                        const SizedBox(height: 48),
                        _buildLoginForm(),
                        const SizedBox(height: 40),
                        Text(
                          'Versión 1.0.0',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  }