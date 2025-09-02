import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dashboard.dart';
import 'booking_page.dart';

// Enum para tipos de usuario
enum UserType { client, barber, admin }

// Clase para manejar el estado de autenticación
class AuthService {
  static UserType? _currentUserType;
  static String? _currentUserId;
  static String? _currentUserName;

  static UserType? get currentUserType => _currentUserType;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;
  static bool get isAuthenticated => _currentUserType != null;
  static bool get isBarber => _currentUserType == UserType.barber || _currentUserType == UserType.admin;

  static void login(UserType userType, String userId, String userName) {
    _currentUserType = userType;
    _currentUserId = userId;
    _currentUserName = userName;
  }

  static void logout() {
    _currentUserType = null;
    _currentUserId = null;
    _currentUserName = null;
  }
}

// Pantalla principal que decide qué mostrar
class AuthWrapper extends StatelessWidget {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAuthenticated) {
      return LoginScreen();
    }

    // Si es barbero/admin, mostrar dashboard
    if (AuthService.isBarber) {
      return AdminDashboard();
    }

    // Si es cliente, mostrar solo el booking
    return ClientBookingWrapper();
  }
}

// Pantalla de login/selección
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);
  final Color cardBg = const Color(0xFF1A1A1A);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Header
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, Color(0xFFE6C86A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cut,
                      size: 60,
                      color: darkBg,
                    ),
                  ),
                  SizedBox(height: 40),

                  Text(
                    'BARBERÍA PREMIUM',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 60),

                  Text(
                    '¿Cómo quieres acceder?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40),

                  // Botón Cliente
                  _buildAccessButton(
                    title: 'SOY CLIENTE',
                    subtitle: 'Quiero agendar una cita',
                    icon: Icons.person,
                    gradient: [Color(0xFF3498DB), Color(0xFF2980B9)],
                    onTap: () => _loginAsClient(),
                  ),

                  SizedBox(height: 20),

                  // Botón Barbero
                  _buildAccessButton(
                    title: 'SOY BARBERO',
                    subtitle: 'Acceder al panel de administración',
                    icon: Icons.admin_panel_settings,
                    gradient: [accentColor, Color(0xFFE6C86A)],
                    onTap: () => _showBarberLogin(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withOpacity(0.2)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.first.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: gradient.first,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _loginAsClient() {
    AuthService.login(UserType.client, 'client_${DateTime.now().millisecondsSinceEpoch}', 'Cliente');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ClientBookingWrapper()),
    );
  }

  void _showBarberLogin() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BarberLoginModal(),
    );
  }
}

// Modal de login para barberos
class BarberLoginModal extends StatefulWidget {
  @override
  _BarberLoginModalState createState() => _BarberLoginModalState();
}

class _BarberLoginModalState extends State<BarberLoginModal> {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);
  final Color cardBg = const Color(0xFF1A1A1A);

  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  // Códigos de acceso (en producción esto estaría en Firebase)
  final Map<String, Map<String, dynamic>> _accessCodes = {
    'FERNANDO2024': {
      'name': 'Fernando Badilla',
      'id': 'fernando',
      'type': UserType.barber,
    },
    'JORGE2024': {
      'name': 'Jorge Castaños',
      'id': 'jorge',
      'type': UserType.barber,
    },
    'ADMIN2024': {
      'name': 'Administrador',
      'id': 'admin',
      'type': UserType.admin,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Header
            Text(
              'Acceso de Barbero',
              style: TextStyle(
                color: accentColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),

            // Código de acceso
            Container(
              decoration: BoxDecoration(
                color: darkBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _codeController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Código de Acceso',
                  labelStyle: TextStyle(color: accentColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Botón de login
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, Color(0xFFE6C86A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(darkBg),
                )
                    : Text(
                  'ACCEDER',
                  style: TextStyle(
                    color: darkBg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Códigos de prueba (solo para desarrollo)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Códigos de prueba:',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• FERNANDO2024 (Fernando Badilla)\n• JORGE2024 (Jorge Castaños)\n• ADMIN2024 (Administrador)',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attemptLogin() async {
    String code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError('Por favor ingresa un código');
      return;
    }

    setState(() => _isLoading = true);

    // Simular delay de autenticación
    await Future.delayed(Duration(seconds: 1));

    if (_accessCodes.containsKey(code)) {
      var userData = _accessCodes[code]!;

      AuthService.login(
        userData['type'],
        userData['id'],
        userData['name'],
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else {
      setState(() => _isLoading = false);
      _showError('Código incorrecto');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Wrapper para clientes (solo booking)
class ClientBookingWrapper extends StatelessWidget {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: Text(
          'Agendar Cita',
          style: TextStyle(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Icon(Icons.exit_to_app, color: accentColor),
          ),
        ],
      ),
      body: BookingPage(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Quieres volver a la pantalla principal?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Salir', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar información del usuario logueado
class UserInfoWidget extends StatelessWidget {
  final Color accentColor = const Color(0xFFC9A23F);

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAuthenticated) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            AuthService.isBarber ? Icons.admin_panel_settings : Icons.person,
            color: accentColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            '${AuthService.currentUserName}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          if (AuthService.isBarber)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BARBERO',
                style: TextStyle(
                  color: Color(0xFF0F0F0F),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}