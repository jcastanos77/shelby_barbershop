import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'models/PaymentErrorScreen.dart';
import 'package:url_launcher/url_launcher.dart';

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

      debugPrint("ID: $appointmentId");

      final result = await callable.call({
        'appointmentId': appointmentId,
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
      print(e);
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
    await launchUrl(
      Uri.parse(checkoutUrl),
      mode: LaunchMode.platformDefault,
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Confirmar pago"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Anticipo",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${depositAmount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white12),

                _infoRow("Cliente", clientName),
                _infoRow("Servicio", service),
                _infoRow("Hora", "$dateKey · $hourKey"),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _pay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Pagar con Mercado Pago",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  "Pago seguro · Se confirmará automáticamente",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}