import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'models/PaymentErrorScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  final String barberId;
  final String dateKey;
  final String hourKey;
  final String clientName;
  final String service;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.barberId,
    required this.dateKey,
    required this.hourKey,
    required this.clientName,
    required this.service,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  bool processing = false;

  Future<void> _pay() async {

    if (processing) return; // 🔥 evita doble click

    setState(() => processing = true);

    try {

      final appointmentId =
          FirebaseDatabase.instance.ref().push().key;

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('createMpPreference');

      final result = await callable.call({
        'appointmentId': appointmentId,
        'amount': widget.totalAmount,
        'barberId': widget.barberId,
        'dateKey': widget.dateKey,
        'hourKey': widget.hourKey,
        'clientName': widget.clientName,
        'service': widget.service,
      });

      final checkoutUrl = result.data['init_point'];

      await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );

    } catch (e) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentErrorScreen(
            message: 'No se pudo iniciar el pago.',
          ),
        ),
      );

    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
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
                  "\$${widget.totalAmount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white12),

                _infoRow("Cliente", widget.clientName),
                _infoRow("Servicio", widget.service),
                _infoRow("Fecha", widget.dateKey),
                _infoRow("Hora", widget.hourKey),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: processing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: processing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Pagar con Mercado Pago",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    "Pago seguro · Se confirmará automáticamente",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
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
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
