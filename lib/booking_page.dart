import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> services = [
    {
      "name": "Corte de cabello",
      "icon": Icons.content_cut,
      "price": "\$250",
      "duration": "30 min"
    },
    {
      "name": "Arreglo de barba",
      "icon": Icons.face_retouching_natural,
      "price": "\$180",
      "duration": "20 min"
    },
    {
      "name": "Corte + Barba",
      "icon": Icons.face,
      "price": "\$400",
      "duration": "45 min"
    },
    {
      "name": "Tinte",
      "icon": Icons.brush,
      "price": "\$350",
      "duration": "60 min"
    }
  ];

  late String selectedService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedService = services.first['name'];
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
    _animationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAppointment() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      _showSnackBar("Por favor, completa todos los campos", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final DateTime appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('appointments').add({
        'name': nameController.text,
        'phone': phoneController.text,
        'service': selectedService,
        'date': appointmentDateTime,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("¡Cita agendada exitosamente!", Colors.green);
      _resetForm();
    } catch (e) {
      _showSnackBar("Error al agendar la cita", Colors.red);
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
      selectedService = services.first['name'];
      selectedDate = null;
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Agendar Cita",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.cut, color: Colors.white, size: 32),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Barbería Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Reserva tu cita perfecta",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Personal Info Section
              _buildSectionTitle("Información Personal"),
              SizedBox(height: 15),
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

              // Service Selection
              _buildSectionTitle("Selecciona tu Servicio"),
              SizedBox(height: 15),
              _buildServiceSelector(),
              SizedBox(height: 30),

              // Date & Time Section
              _buildSectionTitle("Fecha y Hora"),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDateSelector()),
                  SizedBox(width: 15),
                  Expanded(child: _buildTimeSelector()),
                ],
              ),
              SizedBox(height: 40),

              // Book Button
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
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

  Widget _buildServiceSelector() {
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
      child: Column(
        children: services.map((service) {
          bool isSelected = selectedService == service['name'];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF3498DB).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(0xFF3498DB) : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Icon(
                service['icon'],
                color: isSelected ? Color(0xFF3498DB) : Color(0xFF7F8C8D),
                size: 28,
              ),
              title: Text(
                service['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Color(0xFF2C3E50) : Color(0xFF5D6D7E),
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    service['price'],
                    style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    service['duration'],
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onTap: () => setState(() => selectedService = service['name']),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
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
          setState(() => selectedDate = picked);
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
    return GestureDetector(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
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
          setState(() => selectedTime = picked);
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
                  ? "Seleccionar"
                  : selectedTime!.format(context),
              style: TextStyle(
                fontSize: 16,
                color: selectedTime == null ? Color(0xFF7F8C8D) : Color(0xFF2C3E50),
                fontWeight: selectedTime == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
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
              "Agendar Cita",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}