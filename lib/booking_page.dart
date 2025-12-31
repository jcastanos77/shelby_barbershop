import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import 'models/BarberModel.dart';
import 'models/ServiceModel.dart';

class BookingPage extends StatefulWidget {

  final List<ServiceModel> services;
  final List<BarberModel> barbers;

  const BookingPage({
    super.key,
    required this.services,
    required this.barbers,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with TickerProviderStateMixin {
  // Colores consistentes con el home
  final Color accentColor = const Color(0xFFC9A23F);
  final Color darkBg = const Color(0xFF0F0F0F);
  final Color cardBg = const Color(0xFF1A1A1A);

  String formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String formatHour(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';


  // Horarios de trabajo
  final Map<int, List<int>> workingHours = {
    1: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Lunes
    2: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Martes
    3: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Miércoles
    4: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Jueves
    5: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Viernes
    6: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], // Sábado
    7: [10, 11, 12, 13, 14, 15, 16], // Domingo
  };

  String selectedService = "Corte de cabello";
  String? selectedBarberId;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<TimeOfDay> availableSlots = [];
  bool isLoading = false;
  bool isLoadingSlots = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots() async {
    if (selectedDate == null || selectedBarberId == null) return;

    setState(() => isLoadingSlots = true);

    final dateKey = formatDate(selectedDate!);
    final barberId = selectedBarberId!;

    List<int> working = workingHours[selectedDate!.weekday] ?? [];
    List<TimeOfDay> slots = [];

    try {
      for (int hour in working) {
        for (int minute in [0, 45]) {
          final time = TimeOfDay(hour: hour, minute: minute);
          final hourKey = formatHour(time);

          final ref = FirebaseDatabase.instance
              .ref('appointments/$barberId/$dateKey/$hourKey');

          final snap = await ref.get();

          if (!snap.exists) {
            // No permitir pasado
            final slotTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              hour,
              minute,
            );

            if (slotTime.isAfter(DateTime.now())) {
              slots.add(time);
            }
          }
        }
      }

      setState(() {
        availableSlots = slots;
        selectedTime = null;
      });
    } catch (e) {
      _showSnackBar('Error cargando horarios', Colors.red);
    } finally {
      setState(() => isLoadingSlots = false);
    }
  }

  // Nueva función para agregar al calendario
  Future<void> _addToCalendar(DateTime appointmentDateTime, int serviceDuration, String barberName) async {
    try {
      final service = widget.services.firstWhere((s) => s.name == selectedService);
      final servicePrice = service.price;

      final Event event = Event(
        title: '$selectedService - Barbería',
        description: 'Cita en barbería\n'
            'Servicio: $selectedService ($servicePrice)\n'
            'Barbero: $barberName\n'
            'Cliente: ${nameController.text}\n'
            'Teléfono: ${phoneController.text}\n'
            'Duración: $serviceDuration minutos',
        location: 'Barbería - [Agregar dirección aquí]',
        startDate: appointmentDateTime,
        endDate: appointmentDateTime.add(Duration(minutes: serviceDuration)),
        iosParams: IOSParams(
          reminder: Duration(minutes: 30), // Recordatorio 30 min antes
          url: 'https://tu-barberia.com', // URL opcional de tu barbería
        ),
        androidParams: AndroidParams(
          emailInvites: [], // Lista vacía por defecto
        ),
      );

      final bool? result = await Add2Calendar.addEvent2Cal(event);

      if (result == true) {
        _showSnackBar("✅ Evento agregado al calendario", Colors.green);
      } else {
        _showSnackBar("❌ No se pudo agregar al calendario", Colors.orange);
      }
    } catch (e) {
      print("Error adding to calendar: $e");
      _showSnackBar("Error al agregar al calendario", Colors.red);
    }
  }

  // Función para mostrar diálogo de confirmación de calendario
  Future<void> _showCalendarDialog(DateTime appointmentDateTime, int serviceDuration, String barberName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor.withOpacity(0.1), accentColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '¡Cita Confirmada!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkBg,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 ${appointmentDateTime.day}/${appointmentDateTime.month}/${appointmentDateTime.year}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '⏰ ${TimeOfDay.fromDateTime(appointmentDateTime).format(context)}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '✂️ $selectedService',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '👨‍🦲 $barberName',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
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

  Future<void> _saveAppointment() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedBarberId == null ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showSnackBar('Completa todos los campos', Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    final dateKey = formatDate(selectedDate!);
    final hourKey = formatHour(selectedTime!);
    final barberId = selectedBarberId!;

    final service = widget.services.firstWhere((s) => s.name == selectedService);

    final ref = FirebaseDatabase.instance
        .ref('appointments/$barberId/$dateKey/$hourKey');

    try {
      final result = await ref.runTransaction((current) {
        if (current != null) {
          return Transaction.abort();
        }

        return Transaction.success({
          'clientName': nameController.text,
          'phone': phoneController.text,
          'service': selectedService,
          'price': service.price,
          'duration': service.duration,
          'status': 'confirmed',
          'createdAt': ServerValue.timestamp,
        });
      });

      if (!result.committed) {
        _showSnackBar('Ese horario ya fue reservado', Colors.red);
        return;
      }

      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final barberName =
      widget.barbers.firstWhere((b) => b.id == barberId).name;

      _showSnackBar('Cita confirmada con $barberName', Colors.green);
      await _showCalendarDialog(
          appointmentDateTime, service.duration, barberName);

      _resetForm();
    } catch (e) {
      _showSnackBar('Error al guardar la cita', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetForm() {
    nameController.clear();
    phoneController.clear();
    setState(() {
      selectedService = widget.services.first.name;
      selectedBarberId = null;
      selectedDate = null;
      selectedTime = null;
      availableSlots = [];
      currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(
          "Agendar Cita",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: accentColor,
          ),
        ),
        backgroundColor: darkBg,
        foregroundColor: accentColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressIndicator(),
              SizedBox(height: 30),
              _buildStepContent(),
              SizedBox(height: 40),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, "Servicio", Icons.design_services),
          Expanded(child: _buildProgressLine(currentStep > 0)),
          _buildStepIndicator(1, "Barbero", Icons.person),
          Expanded(child: _buildProgressLine(currentStep > 1)),
          _buildStepIndicator(2, "Fecha", Icons.calendar_today),
          Expanded(child: _buildProgressLine(currentStep > 2)),
          _buildStepIndicator(3, "Datos", Icons.edit),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, IconData icon) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? accentColor : Colors.grey[700],
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: accentColor, width: 3) : null,
          ),
          child: Icon(
            icon,
            color: isActive ? darkBg : Colors.grey[400],
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 3,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? accentColor : Colors.grey[700],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildServiceSelection();
      case 1:
        return _buildBarberSelection();
      case 2:
        return _buildDateTimeSelection();
      case 3:
        return _buildPersonalInfo();
      default:
        return Container();
    }
  }

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Selecciona tu Servicio"),
        SizedBox(height: 20),
        ...widget.services.map((service) => _buildServiceCard(service)).toList(),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    bool isSelected = selectedService == service.name;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.grey : Colors.grey[600]!,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.cut,
            color: Colors.grey,
            size: 32,
          ),
        ),
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "${service.duration} min",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: Text(
          '\$${service.price}',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          setState(() {
            selectedService = service.name;
            // Reset selections that depend on service
            selectedTime = null;
            availableSlots = [];
          });
        },
      ),
    );
  }

  Widget _buildBarberSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Selecciona tu Barbero"),
        SizedBox(height: 20),
        ...widget.barbers.map((barber) => _buildBarberCard(barber)).toList(),
      ],
    );
  }

  Widget _buildBarberCard(BarberModel barber) {
    bool isSelected = selectedBarberId == barber.id;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.red : Colors.grey[200]!,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              'barber',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        title: Text(
          barber.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              "Experiencia: ${6 }años",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  "${5}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            selectedBarberId = barber.id;
            // Reset time selection when barber changes
            selectedTime = null;
            availableSlots = [];
          });
          // Load available slots if date is already selected
          if (selectedDate != null) {
            _loadAvailableSlots();
          }
        },
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Fecha y Hora"),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildDateSelector()),
            SizedBox(width: 15),
            Expanded(child: _buildTimeSelector()),
          ],
        ),
        if (availableSlots.isNotEmpty) ...[
          SizedBox(height: 30),
          _buildSectionTitle("Horarios Disponibles"),
          SizedBox(height: 15),
          _buildTimeSlots(),
        ],
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 60)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: Color(0xFF3498DB)),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            selectedTime = null;
          });
          if (selectedBarberId != null) {
            _loadAvailableSlots();
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF3498DB), size: 20),
                SizedBox(width: 8),
                Text(
                  "Fecha",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              selectedDate == null
                  ? "Seleccionar"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: TextStyle(
                fontSize: 16,
                color: selectedDate == null ? Color(0xFF7F8C8D) : Color(0xFF2C3E50),
                fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 8),
              Text(
                "Hora",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            selectedTime == null
                ? "Selecciona fecha y barbero"
                : selectedTime!.format(context),
            style: TextStyle(
              fontSize: 16,
              color: selectedTime == null ? Color(0xFF7F8C8D) : Color(0xFF2C3E50),
              fontWeight: selectedTime == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (isLoadingSlots) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: availableSlots.map((slot) {
          bool isSelected = selectedTime == slot;
          return GestureDetector(
            onTap: () => setState(() => selectedTime = slot),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF3498DB) : Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Color(0xFF3498DB) : Colors.grey[300]!,
                ),
              ),
              child: Text(
                slot.format(context),
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF2C3E50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Información Personal"),
        SizedBox(height: 20),
        _buildTextField(
          controller: nameController,
          label: "Nombre completo",
          icon: Icons.person,
          hint: "Ej. Juan Pérez",
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: phoneController,
          label: "Teléfono",
          icon: Icons.phone,
          hint: "Ej. 644 123 4567",
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 30),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    if (selectedService.isEmpty || selectedBarberId == null || selectedDate == null || selectedTime == null) {
      return Container();
    }

    final service = widget.services.firstWhere((s) => s.name == selectedService);
    final barber = widget.barbers.firstWhere((b) => b.id == selectedBarberId);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumen de tu Cita",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow("Servicio", selectedService, '${service.price}'),
          _buildSummaryRow("Barbero", barber.name, ""),
          _buildSummaryRow("Fecha", "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}", ""),
          _buildSummaryRow("Hora", selectedTime!.format(context), ""),
          _buildSummaryRow("Duración", "${service.duration} min", ""),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String extra) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              "$value $extra",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Color(0xFF34495E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        if (currentStep < 3)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              onPressed: _canProceedToNext() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Continuar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (currentStep == 3)
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF27AE60), Color(0xFF229954)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF27AE60).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Confirmar Cita",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (currentStep > 0) ...[
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF3498DB), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Regresar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3498DB),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: accentColor,
      ),
    );
  }

  bool _canProceedToNext() {
    switch (currentStep) {
      case 0:
        return selectedService.isNotEmpty;
      case 1:
        return selectedBarberId != null;
      case 2:
        return selectedDate != null && selectedTime != null;
      case 3:
        return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNext() && currentStep < 3) {
      setState(() => currentStep++);
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }
}