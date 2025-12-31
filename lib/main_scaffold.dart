import 'package:barbershop/services/LandingBarbersService.dart';
import 'package:barbershop/services/LandingServicesService.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_dashboard.dart';
import 'booking_page.dart';
import 'models/BarberModel.dart';
import 'models/ServiceModel.dart';

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);
  final Color cardBg = const Color(0xFF1A1A1A);

  late AnimationController _heroController;
  late AnimationController _servicesController;
  late AnimationController _galleryController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _servicesStagger;
  late Animation<double> _galleryStagger;

  final _servicesService = LandingServicesService();
  final _barbersService = LandingBarbersService();

  List<ServiceModel> servicesF = [];
  List<BarberModel> barbers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
    _setupAnimations();
    _startAnimations();
  }

  Future<void> load() async {
    servicesF = await _servicesService.getServices();
    barbers = await _barbersService.getBarbers();
    setState(() => loading = false);
  }
  final List<Map<String, dynamic>> services = const [
    {
      'name': 'Corte + Facial',
      'price': '\$220',
      'icon': 'cut',
      'description': 'Corte de cabello mas mascarilla.',
      'descriptionLarge':'Corte de cabello más... mascarilla de puntos negros, crema exfoliante para remover y limpiar células muertas, mascarilla hidratante de colágeno, todo con vapor para abrir los poros, al final una crema para el cuidado de tu piel, incluyendo masaje',
      'duration': '45 min',
      'gradient': [0xFF8B4513, 0xFFA0522D]
    },
    {
      'name': 'Corte Vip',
      'price': '\$400',
      'icon': 'face',
      'description': 'Corte, secado y peinado',
      'descriptionLarge':'Corte de cabello, secado y peinado, arreglo de barba y bigote con vapor mascarilla de puntos negros y exfoliación facial, mascarilla de colágeno para hidratar piel, mascarilla para ojera, arreglo de cejas y aplicación de Wax, incluyendo masaje',
      'duration': '45 min',
      'gradient': [0xFF2E8B57, 0xFF3CB371],
    },
    {
      'name': 'Corte + Barba',
      'price': '\$250',
      'icon': 'content_cut',
      'description': 'Servicio completo de lujo',
      'descriptionLarge':'Corte de cabello, secado y peinado, arreglo de barba y bigote con vapor con aplicación de crema y aceites para el cuidado de tu barba, incluyendo masaje',
      'duration': '45 min',
      'gradient': [0xFF4169E1, 0xFF1E90FF]
    },
  ];


  final List<Map<String, dynamic>> servicesClasics = const [
    {
      'name': 'Corte de pelo clásico',
      'price': '\$150',
      'color': 0xFF4169E1
    },{
      'name': 'Corte de pelo rasurado',
      'price': '\$160',
      'color': 0xFF4169E1
    },{
      'name': 'Limpieza de barba',
      'price': '\$100',
      'color': 0xFF4169E1
    },{
      'name': 'Tinte de barba',
      'price': '\$80',
      'color': 0xFF4169E1
    },{
      'name': 'Tinte de cabello',
      'price': '\$130',
      'color': 0xFF4169E1
    },{
      'name': 'Limpieza de ceja',
      'price': '\$30',
      'color': 0xFF4169E1
    },{
      'name': 'Aplicación de Wax',
      'price': '\$50',
      'color': 0xFF4169E1
    },{
      'name': 'Exfoliación facial',
      'price': '\$100',
      'color': 0xFF4169E1
    },{
      'name': 'Mascarilla negra',
      'price': '\$70',
      'color': 0xFF4169E1
    }
  ];

  final List<String> galleryImages = const [
    'assets/images/gallery1.jpg',
    'assets/images/gallery2.jpg',
    'assets/images/gallery3.jpg',
    'assets/images/gallery4.jpg',
    'assets/images/gallery5.jpg',
    'assets/images/gallery6.jpg',
  ];

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _servicesController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _galleryController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );
    _servicesStagger = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _servicesController, curve: Curves.easeOutBack),
    );
    _galleryStagger = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _galleryController, curve: Curves.easeOut),
    );
  }

  // Funciones para abrir enlaces
  Future<void> _launchInstagram() async {
    const String username = 'shelbysbarbershop_';
    final Uri instagramAppUrl = Uri.parse('instagram://user?username=$username');
    final Uri instagramWebUrl = Uri.parse('https://instagram.com/$username');

    try {
      if (await canLaunchUrl(instagramAppUrl)) {
        await launchUrl(instagramAppUrl);
      } else {
        await launchUrl(instagramWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Fallback: mostrar snackbar si no puede abrir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir Instagram'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para mostrar el login de barberos
  void _showBarberLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBarberLoginModal(context),
    );
  }

  // Modal de login para barberos
  Widget _buildBarberLoginModal(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;

    // Códigos de acceso para barberos
    final Map<String, Map<String, dynamic>> accessCodes = {
      'FERNANDO2024': {'name': 'Fernando Badilla', 'id': 'fernando'},
      'JORGE2024': {'name': 'Jorge Castaños', 'id': 'jorge'},
      'ADMIN2024': {'name': 'Administrador', 'id': 'admin'},
    };

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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

                // Header con icono
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accentColor, Color(0xFFE6C86A)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(Icons.admin_panel_settings, size: 40, color: darkBg),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Acceso de Barbero',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Panel de administración',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Campo de código
                Container(
                  decoration: BoxDecoration(
                    color: darkBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: codeController,
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
                      hintText: 'Ejemplo: FERNANDO',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                    onSubmitted: (_) => _attemptLogin(context, codeController, accessCodes, setState),
                  ),
                ),

                SizedBox(height: 30),

                // Botón de login
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, Color(0xFFE6C86A)]),
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
                    onPressed: isLoading ? null : () => _attemptLogin(context, codeController, accessCodes, setState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(darkBg),
                      strokeWidth: 3,
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: darkBg),
                        SizedBox(width: 12),
                        Text(
                          'ACCEDER AL PANEL',
                          style: TextStyle(
                            color: darkBg,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para intentar hacer login
  void _attemptLogin(BuildContext context, TextEditingController codeController,
      Map<String, Map<String, dynamic>> accessCodes, StateSetter setState) async {
    String code = codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError(context, 'Por favor ingresa tu código de acceso');
      return;
    }

    setState(() => true); // isLoading = true

    await Future.delayed(Duration(milliseconds: 800));

    if (accessCodes.containsKey(code)) {
      // Navegar al dashboard
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AdminDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      setState(() => false); // isLoading = false
      _showError(context, 'Código incorrecto. Verifica tu código de acceso.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _launchPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+526442030885');
    try {
      await launchUrl(phoneUrl);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir la aplicación de teléfono'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchMaps() async {
    const String address = 'Chiapas sur 606, Ciudad Obregón';
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startAnimations() async {
    await _heroController.forward();
    await Future.delayed(Duration(milliseconds: 200));
    await _servicesController.forward();
    await Future.delayed(Duration(milliseconds: 100));
    await _galleryController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _servicesController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'cut':
        return Icons.cut;
      case 'face':
        return Icons.face;
      case 'content_cut':
        return Icons.content_cut;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    int galleryCrossAxisCount = screenWidth > 900 ? 3 : screenWidth > 600 ? 2 : 2;
    bool isMobile = screenWidth < 600;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,

      floatingActionButton: _buildFloatingActionButton(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(screenHeight),
                _buildServicesSection(isMobile),
                _buildStatsSection(),
                _buildGallerySection(galleryCrossAxisCount),
                _buildTestimonialsSection(),
                _buildContactSection(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [accentColor, Color(0xFFE6C86A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.calendar_today, color: darkBg, size: 24),
        label: Text(
          'AGENDAR CITA',
          style: TextStyle(
            color: darkBg,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => BookingPage(barbers: barbers, services: servicesF,),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(double screenHeight) {
    return Container(
      height: screenHeight * 0.8,
      child: Stack(
        children: [
          // Background with parallax effect
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hero_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                  darkBg.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _heroController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'DESDE 2024',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "SHELBY'S",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 8,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            'BARBER',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              height: 0.9,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 100,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, accentColor, Colors.transparent],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Tradición, elegancia y estilo en cada corte',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionHeader('NUESTROS SERVICIOS ESPECIALES', 'La experiencia que mereces'),
          SizedBox(height: 60),
          AnimatedBuilder(
            animation: _servicesController,
            builder: (context, child) {
              return _buildMobileServices();
            },
          ),
          SizedBox(height: 20),
         _buildSectionHeader('NUESTROS SERVICIOS CLASICOS', 'Lo mejor de la ciudad'),
          SizedBox(height: 20),
        AnimatedBuilder(
            animation: _servicesController,
            builder: (context, child) {
              return _buildClasicServices();
            }),
        ],
      ),
    );
  }

  Widget _buildClasicServices(){
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: servicesF.length,
        itemBuilder: (context, index) {
          final servicio = servicesF[index];
          return Container(
            height: 90,
            margin: EdgeInsets.only(bottom: 12.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.content_cut,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      servicio.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${servicio.price}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          },
      ),
    );
  }

  void _mostrarDetalleServicio(BuildContext context, Servicio servicio) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  servicio.color.withOpacity(0.1),
                  servicio.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con gradiente
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFC9A23F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.content_cut,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        servicio.nombre,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          servicio.precio,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: servicio.color,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Descripción del servicio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        servicio.descriptionLarge,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 24),

                      // Información adicional
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: servicio.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: servicio.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: servicio.color,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Duración aproximada: 30-45 minutos',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cerrar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileServices() {
    final filtered = servicesF
        .where((s) => s.isSpecial == true)
        .toList();

    if (filtered.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        itemCount: filtered.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Transform.scale(
            scale: _servicesStagger.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildServiceCard(index, filtered[index]),
            ),
          );
        },
      ),
    );
  }


  Widget _buildServiceCard(int index, ServiceModel serviceData) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.red,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _iconFromString('cut'),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  serviceData.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  serviceData.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${serviceData.price}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${serviceData.duration} min',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        _mostrarDetalleServicio(context, Servicio(nombre: serviceData.name, precio: '\$${serviceData.price}', descriptionLarge: serviceData.description, color: Colors.grey));
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardBg, darkBg],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('500+', 'Clientes\nSatisfechos'),
          _buildStatItem('25+', 'Años de\nExperiencia'),
          _buildStatItem('100%', 'Calidad\nGarantizada'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            color: accentColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection(int crossAxisCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          _buildSectionHeader('NUESTRA GALERÍA', 'El arte de nuestro trabajo'),
          SizedBox(height: 60),
          AnimatedBuilder(
            animation: _galleryController,
            builder: (context, child) {
              return Transform.scale(
                scale: _galleryStagger.value,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: galleryImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    String url = entry.value;
                    return _buildGalleryItem(url, index);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(String url, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: cardBg,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: accentColor.withOpacity(0.5),
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBg, cardBg],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader('LO QUE DICEN NUESTROS CLIENTES', 'Testimonios reales'),
          SizedBox(height: 60),
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) =>
                      Icon(Icons.star, color: accentColor, size: 24)),
                ),
                SizedBox(height: 20),
                Text(
                  '"La mejor barbería de la ciudad. Excelente servicio y atención al detalle. Siempre salgo satisfecho con mi corte."',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '- Carlos M.',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          _buildSectionHeader('CONTÁCTANOS', 'Estamos aquí para ti'),
          SizedBox(height: 60),
          Row(
            children: [
              Expanded(child: _buildContactCard(Icons.phone, '644 203 0885', 'Llámanos', () => _launchPhone())),
              SizedBox(width: 16),
              Expanded(child: _buildContactCard(Icons.camera_alt, '@shelbysbarbershop_', 'Síguenos', () => _launchInstagram())),
            ],
          ),
          SizedBox(height: 16),
          _buildContactCard(Icons.location_on, 'C. Chiapas Sur 606, Col. Hidalgo Cd. Obregón', 'Visítanos', () => _launchMaps(), isFullWidth: true),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String info, String label, VoidCallback? onTap, {bool isFullWidth = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              info,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  'Tocar para abrir',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: accentColor.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Text(
            'Shelby´s BarberShop',
            style: TextStyle(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tradición y elegancia desde 2024',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white12),
          SizedBox(height: 16),
          Text(
            '© 2024 Shelby´s BarberShop. Todos los derechos reservados.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, accentColor, Colors.transparent],
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Servicio {
  final String nombre;
  final String precio;
  final String descriptionLarge;
  final Color color;

  Servicio({
    required this.nombre,
    required this.precio,
    required this.descriptionLarge,
    required this.color,
  });
}