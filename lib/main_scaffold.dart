import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_page.dart';
import 'services_page.dart';
import 'concact_page.dart';
import 'galeria_page.dart';
import 'home_page.dart';

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

  final List<Map<String, dynamic>> services = const [
    {
      'name': 'Corte Clásico',
      'price': '\$150',
      'icon': 'cut',
      'description': 'Corte tradicional con tijera y navaja',
      'duration': '30 min',
      'gradient': [0xFF8B4513, 0xFFA0522D]
    },
    {
      'name': 'Afeitado Premium',
      'price': '\$120',
      'icon': 'face',
      'description': 'Afeitado clásico con toalla caliente',
      'duration': '25 min',
      'gradient': [0xFF2E8B57, 0xFF3CB371]
    },
    {
      'name': 'Corte + Barba',
      'price': '\$250',
      'icon': 'content_cut',
      'description': 'Servicio completo de lujo',
      'duration': '45 min',
      'gradient': [0xFF4169E1, 0xFF1E90FF]
    },
  ];

  final List<String> galleryImages = const [
    'assets/images/gallery1.jpg',
    'assets/images/gallery2.jpg',
    'assets/images/gallery3.jpg',
    'assets/images/gallery4.jpg',
    'assets/images/gallery5.jpg',
    'assets/images/gallery6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

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

  Future<void> _launchPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+526642030885');
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

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: SingleChildScrollView(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'SHELBY´S BARBERSHOP',
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      centerTitle: true,
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
              pageBuilder: (context, animation, secondaryAnimation) => BookingPage(),
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
                            'SHELBY´S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 8,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            'BARBERSHOP',
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
          _buildSectionHeader('NUESTROS SERVICIOS', 'La experiencia que mereces'),
          SizedBox(height: 60),
          AnimatedBuilder(
            animation: _servicesController,
            builder: (context, child) {
              return isMobile
                  ? _buildMobileServices()
                  : _buildDesktopServices();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileServices() {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: services.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Transform.scale(
            scale: _servicesStagger.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: _buildServiceCard(services[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopServices() {
    return Row(
      children: services.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> service = entry.value;
        return Expanded(
          child: Transform.scale(
            scale: _servicesStagger.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: _buildServiceCard(service, index),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(service['gradient'][0]),
            Color(service['gradient'][1]),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(service['gradient'][0]).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
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
                    _iconFromString(service['icon']!),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  service['name']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  service['description']!,
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
                          service['price']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          service['duration']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
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
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.zoom_in,
                  color: darkBg,
                  size: 20,
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
          _buildSectionHeader('CONTÁCTANOS', 'Disfruta del mejor servicio'),
          SizedBox(height: 60),
          Row(
            children: [
              Expanded(child: _buildContactCard(Icons.phone, '664 203 0885', 'Llámanos', () => _launchPhone())),
              SizedBox(width: 16),
              Expanded(child: _buildContactCard(Icons.camera_alt, '@shelbysbarbershop_', 'Síguenos', () => _launchInstagram())),
            ],
          ),
          SizedBox(height: 16),
          _buildContactCard(Icons.location_on, 'C. Chiapas sur 606 Col. Hidalgo, Cd. Obregón', 'Visítanos', () => _launchMaps(), isFullWidth: true),
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
            "SHELBY'S BARBERSHOP",
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