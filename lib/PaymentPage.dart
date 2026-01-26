import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'PaymentSuccessScreen.dart';
import 'models/PaymentErrorScreen.dart';

class PaymentPage extends StatelessWidget {
  final int depositAmount;
  final String barberId;
  final String dateKey;
  final String hourKey;
  final String clientName;
  final String service;

  const PaymentPage({
    super.key,
    required this.depositAmount,
    required this.barberId,
    required this.dateKey,
    required this.hourKey,
    required this.clientName,
    required this.service,
  });

  Future<void> _pay(BuildContext context) async {
    late String checkoutUrl;
    final db = FirebaseDatabase.instance.ref();
    final appointmentId = db.child('appointments').push().key;

    try {

      if (appointmentId == null) {
        throw Exception('No se pudo generar appointmentId');
      }

      await db.child('appointments/$appointmentId').set({
        'barberId': barberId,
        'clientName': clientName,
        'service': service,
        'dateKey': dateKey,
        'hourKey': hourKey,
        'amount': depositAmount,
        'paid': false,
        'paymentStatus': 'pending_payment',
        'createdAt': ServerValue.timestamp,
      });

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('createMpPreference');

      final result = await callable.call({
        'amount': depositAmount,
        'barberId': barberId,
        'dateKey': dateKey,
        'hourKey': hourKey,
        'clientName': clientName,
        'service': service,
      });

      checkoutUrl = result.data['init_point'];
      debugPrint("✅ CHECKOUT URL: $checkoutUrl");

    } catch (e) {

      await db.child('appointments/$appointmentId').remove();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentErrorScreen(
            message: 'No se pudo iniciar el pago.',
          ),
        ),
      );
      return;
    }

    // 🚀 REDIRECCIÓN FUERA DEL TRY
    html.window.location.href = checkoutUrl;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Pagar anticipo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Anticipo: \$${depositAmount}",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _pay(context),
              child: Text("Pagar con MercadoPago"),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentResultWeb extends StatelessWidget {
  const PaymentResultWeb({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí capturamos la URL de retorno de MercadoPago
    final uri = Uri.base;
    final status = uri.queryParameters['status']; // 'approved', 'rejected', etc.

    // Dependiendo del status, mostramos la pantalla correspondiente
    if (status == 'approved') {
      return PaymentSuccessScreen(
        clientName: uri.queryParameters['clientName'] ?? 'Cliente',
        service: uri.queryParameters['service'] ?? 'Servicio',
      );
    } else {
      return PaymentErrorScreen(
        message: 'El pago no se completó correctamente.',
      );
    }
  }
}