import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'PaymentSuccessScreen.dart';
import 'PaymentErrorScreen.dart';
import 'PaymentPendingScreen.dart';

class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({super.key});

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  StreamSubscription<DatabaseEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _listenAppointment();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // =========================
  // CORE LOGIC
  // =========================
  void _listenAppointment() {
    final uri = Uri.base;

    final appointmentId = uri.queryParameters['id'];
    final statusFromMp = uri.queryParameters['status'];

    if (appointmentId == null) {
      _goError("Cita inválida");
      return;
    }

    final ref = FirebaseDatabase.instance.ref('appointments/$appointmentId');

    /// 🔥 Escuchamos realtime hasta que webhook confirme
    _sub = ref.onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(
        event.snapshot.value as Map,
      );

      final paid = data['paid'] == true;
      final paymentStatus = data['paymentStatus'];

      final clientName = data['clientName'] ?? '';
      final service = data['service'] ?? '';

      // ✅ CONFIRMADO POR WEBHOOK (única verdad)
      if (paid && paymentStatus == "approved") {
        _sub?.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              clientName: clientName,
              service: service,
            ),
          ),
        );
        return;
      }

      if (statusFromMp == "pending") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPendingScreen(),
          ),
        );
        return;
      }

      // ❌ Rechazado
      if (statusFromMp == "rejected") {
        _goError("Pago rechazado");
      }
    });
  }

  void _goError(String msg) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentErrorScreen(message: msg),
      ),
    );
  }

  // =========================
  // UI Loading
  // =========================
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Confirmando pago...",
              style: TextStyle(color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
