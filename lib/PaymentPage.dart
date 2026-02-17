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
    if (processing) return;

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
        webOnlyWindowName: '_self',
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentErrorScreen(
            message: 'No se pudo iniciar el pago.',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => processing = false);
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${widget.totalAmount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: processing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: processing
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}