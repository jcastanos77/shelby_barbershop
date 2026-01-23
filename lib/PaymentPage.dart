import 'dart:html' as html;
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
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createMpPreference');
      print(callable.toString());
      final result = await callable.call({
        'amount': depositAmount,
        'barberId': barberId,
        'dateKey': dateKey,
        'hourKey': hourKey,
        'clientName': clientName,
        'service': service,
      });

      final checkoutUrl = result.data['init_point'];
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception("No se recibió la URL de pago");
      }
      html.window.open(checkoutUrl, "_blank");
    }  on FirebaseFunctionsException catch (e) {
      // Captura errores específicos de Firebase
      html.window.alert("Error de función: ${e.message}");
    } catch (e) {
      // Cualquier otro error
      html.window.alert("Ocurrió un error al iniciar el pago: $e");
    }
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