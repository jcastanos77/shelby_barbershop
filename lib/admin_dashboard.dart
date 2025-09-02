import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_scaffold.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);
  final Color cardBg = const Color(0xFF1A1A1A);

  DateTime selectedDate = DateTime.now();
  String selectedBarber = 'all';
  String selectedView = 'day'; // day, week, month

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> barbers = [
    {
      "id": "fernando",
      "name": "Fernando Badilla",
      "avatar": "👨‍🦲",
      "color": 0xFFC9A23F
    },
    {
      "id": "jorge",
      "name": "Jorge Castaños",
      "avatar": "👨‍🦱",
      "color": 0xFFD4AF37
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentsView(),
            _buildCalendarView(),
            _buildStatsView(),
            _buildSettingsView(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      title: Text(
        'Admin Dashboard',
        style: TextStyle(
          color: accentColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: accentColor,
        labelColor: accentColor,
        unselectedLabelColor: Colors.grey[400],
        tabs: [
          Tab(icon: Icon(Icons.event), text: "Citas"),
          Tab(icon: Icon(Icons.calendar_today), text: "Calendar"),
          Tab(icon: Icon(Icons.bar_chart), text: "Stats"),
          Tab(icon: Icon(Icons.settings), text: "Config"),
        ],
      ),
    );
  }

  Widget _buildAppointmentsView() {
    return Column(
      children: [
        _buildDashboardHeader(), // Header con info del barbero
        _buildFilters(),
        Expanded(child: _buildAppointmentsList()),
      ],
    );
  }

  // Header del dashboard
  Widget _buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.admin_panel_settings, color: accentColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestión de citas y barberos',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: Icon(Icons.exit_to_app, color: accentColor),
            tooltip: 'Volver al inicio',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.home, color: accentColor),
            SizedBox(width: 12),
            Text('Volver al Inicio', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          '¿Quieres volver a la página principal?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accentColor, Color(0xFFE6C86A)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainScaffold()),
                );
              },
              child: Text('Volver', style: TextStyle(color: darkBg, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBarberFilter(),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(Duration(days: 30)),
          lastDate: DateTime.now().add(Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(primary: accentColor),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: darkBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: accentColor, size: 20),
            SizedBox(width: 8),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberFilter() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedBarber,
          dropdownColor: cardBg,
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: accentColor),
          onChanged: (value) => setState(() => selectedBarber = value!),
          items: [
            DropdownMenuItem(value: 'all', child: Text('Todos los barberos')),
            ...barbers.map((barber) => DropdownMenuItem(
              value: barber['id'],
              child: Row(
                children: [
                  Text(barber['avatar'], style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(barber['name']),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Row(
        children: ['day', 'week', 'month'].map((view) {
          bool isSelected = selectedView == view;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedView = view),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  view == 'day' ? 'Día' : view == 'week' ? 'Semana' : 'Mes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? darkBg : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        List<QueryDocumentSnapshot> appointments = snapshot.data!.docs;

        // Ordenar por fecha y hora
        appointments.sort((a, b) {
          DateTime dateA = (a['date'] as Timestamp).toDate();
          DateTime dateB = (b['date'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(appointments[index]);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getAppointmentsStream() {
    Query query = FirebaseFirestore.instance.collection('appointments');

    // Filtrar por barbero si no es 'all'
    if (selectedBarber != 'all') {
      query = query.where('barberId', isEqualTo: selectedBarber);
    }

    // Filtrar por fecha según la vista seleccionada
    DateTime startDate, endDate;

    switch (selectedView) {
      case 'day':
        startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
        break;
      case 'week':
        int daysFromMonday = selectedDate.weekday - 1;
        startDate = selectedDate.subtract(Duration(days: daysFromMonday));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'month':
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
        break;
      default:
        startDate = DateTime.now();
        endDate = DateTime.now().add(Duration(days: 1));
    }

    return query
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots();
  }

  Widget _buildAppointmentCard(QueryDocumentSnapshot appointment) {
    Map<String, dynamic> data = appointment.data() as Map<String, dynamic>;
    DateTime appointmentDate = (data['date'] as Timestamp).toDate();

    // Obtener color del barbero
    Color barberColor = accentColor;
    var barber = barbers.firstWhere(
            (b) => b['id'] == data['barberId'],
        orElse: () => {'color': 0xFFC9A23F}
    );
    barberColor = Color(barber['color']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: barberColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con estado
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [barberColor.withOpacity(0.2), Colors.transparent],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: barberColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: barberColor, size: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      data['barberName'] ?? 'Barbero',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(data['status'] ?? 'confirmed'),
              ],
            ),
          ),

          // Información de la cita
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, 'Cliente', data['name'] ?? ''),
                _buildInfoRow(Icons.phone, 'Teléfono', data['phone'] ?? ''),
                _buildInfoRow(Icons.content_cut, 'Servicio', data['service'] ?? ''),
                _buildInfoRow(Icons.access_time, 'Hora',
                    "${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}"),
                _buildInfoRow(Icons.timer, 'Duración', "${data['serviceDuration'] ?? 30} min"),
              ],
            ),
          ),

          // Botones de acción
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkBg.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Cancelar',
                    Icons.cancel,
                    Colors.red,
                        () => _cancelAppointment(appointment.id),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Reprogramar',
                    Icons.schedule,
                    accentColor,
                        () => _rescheduleAppointment(appointment.id, data),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Completar',
                    Icons.check_circle,
                    Colors.green,
                        () => _completeAppointment(appointment.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmada';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Completada';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'No hay citas para mostrar',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cambia los filtros o la fecha seleccionada',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Vista del calendario
  Widget _buildCalendarView() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Vista de Calendar',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Icon(
                  Icons.calendar_view_month,
                  size: 80,
                  color: accentColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Próximamente: Vista de calendario completa\ncon drag & drop para reprogramar citas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vista de estadísticas
  Widget _buildStatsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          );
        }

        List<QueryDocumentSnapshot> allAppointments = snapshot.data!.docs;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatsCards(allAppointments),
              SizedBox(height: 24),
              _buildBarberStats(allAppointments),
              SizedBox(height: 24),
              _buildServiceStats(allAppointments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(List<QueryDocumentSnapshot> appointments) {
    int totalAppointments = appointments.length;
    int confirmedAppointments = appointments.where((a) =>
    (a.data() as Map<String, dynamic>)['status'] == 'confirmed').length;
    int completedAppointments = appointments.where((a) =>
    (a.data() as Map<String, dynamic>)['status'] == 'completed').length;
    int todayAppointments = appointments.where((a) {
      DateTime appDate = ((a.data() as Map<String, dynamic>)['date'] as Timestamp).toDate();
      DateTime today = DateTime.now();
      return appDate.year == today.year &&
          appDate.month == today.month &&
          appDate.day == today.day;
    }).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Citas', totalAppointments.toString(), Icons.event, accentColor)),
            SizedBox(width: 16),
            Expanded(child: _buildStatCard('Hoy', todayAppointments.toString(), Icons.today, Colors.blue)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Confirmadas', confirmedAppointments.toString(), Icons.check_circle, Colors.green)),
            SizedBox(width: 16),
            Expanded(child: _buildStatCard('Completadas', completedAppointments.toString(), Icons.done_all, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarberStats(List<QueryDocumentSnapshot> appointments) {
    Map<String, int> barberCounts = {};
    for (var appointment in appointments) {
      String barberId = (appointment.data() as Map<String, dynamic>)['barberId'] ?? '';
      barberCounts[barberId] = (barberCounts[barberId] ?? 0) + 1;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Citas por Barbero',
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...barbers.map((barber) {
            int count = barberCounts[barber['id']] ?? 0;
            double percentage = appointments.isEmpty ? 0 : (count / appointments.length);

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(barber['avatar'], style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            barber['name'],
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(
                        '$count citas',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(barber['color'])),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceStats(List<QueryDocumentSnapshot> appointments) {
    Map<String, int> serviceCounts = {};
    for (var appointment in appointments) {
      String service = (appointment.data() as Map<String, dynamic>)['service'] ?? '';
      serviceCounts[service] = (serviceCounts[service] ?? 0) + 1;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicios Más Populares',
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...serviceCounts.entries.map((entry) {
            double percentage = appointments.isEmpty ? 0 : (entry.value / appointments.length);

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${entry.value} citas',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Vista de configuración
  Widget _buildSettingsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsCard(
            'Gestión de Barberos',
            'Agregar, editar o eliminar barberos',
            Icons.people,
                () => _showBarbersManagement(),
          ),
          SizedBox(height: 16),
          _buildSettingsCard(
            'Horarios de Trabajo',
            'Configurar horarios de atención',
            Icons.schedule,
                () => _showScheduleSettings(),
          ),
          SizedBox(height: 16),
          _buildSettingsCard(
            'Servicios y Precios',
            'Gestionar servicios disponibles',
            Icons.content_cut,
                () => _showServicesSettings(),
          ),
          SizedBox(height: 16),
          _buildSettingsCard(
            'Exportar Datos',
            'Descargar reporte de citas',
            Icons.download,
                () => _exportData(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }

  // Funciones de acción
  Future<void> _cancelAppointment(String appointmentId) async {
    bool? confirm = await _showConfirmDialog(
      '¿Cancelar Cita?',
      'Esta acción no se puede deshacer.',
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .update({'status': 'cancelled'});

        _showSnackBar('Cita cancelada exitosamente', Colors.green);
      } catch (e) {
        _showSnackBar('Error al cancelar la cita', Colors.red);
      }
    }
  }

  Future<void> _completeAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'completed'});

      _showSnackBar('Cita marcada como completada', Colors.green);
    } catch (e) {
      _showSnackBar('Error al actualizar la cita', Colors.red);
    }
  }

  Future<void> _rescheduleAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    // Aquí implementarías la lógica de reprogramación
    _showSnackBar('Función de reprogramación próximamente', Colors.orange);
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(title, style: TextStyle(color: Colors.white)),
        content: Text(content, style: TextStyle(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmar', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Placeholder functions para configuraciones
  void _showBarbersManagement() {
    _showSnackBar('Gestión de barberos próximamente', Colors.orange);
  }

  void _showScheduleSettings() {
    _showSnackBar('Configuración de horarios próximamente', Colors.orange);
  }

  void _showServicesSettings() {
    _showSnackBar('Gestión de servicios próximamente', Colors.orange);
  }

  void _exportData() {
    _showSnackBar('Exportación de datos próximamente', Colors.orange);
  }
}