import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';

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

  void _listenAppointment() {
    final appointmentId = Uri.base.queryParameters['id'];

    if (appointmentId == null) {
      _goError("Cita inválida");
      return;
    }

    final ref = FirebaseDatabase.instance.ref('appointments/$appointmentId');

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        context.go('/payment-error?msg=Pago no completado');
      }
    });

    _sub = ref.onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final paid = data['paid'] == true;
      final status = data['paymentStatus'];

      final clientName = data['clientName'] ?? '';
      final service = data['service'] ?? '';

      if (paid && status == "approved") {
        _sub?.cancel();
        context.go('/payment-success?name=$clientName&service=$service');
        return;
      }

      if (status == "rejected") {
        _sub?.cancel();
        context.go('/payment-error?msg=Pago rechazado');
        return;
      }

      if (status == "pending" || status == "pending_payment") {
        _sub?.cancel();
        context.go('/payment-error?msg=Pago pendiente o cancelado');
      }
    });
  }

  void _goError(String msg) {
    context.go('/payment-error?msg=$msg');
  }

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
