import 'package:flutter/material.dart';

class PaymentPendingScreen extends StatelessWidget {
  const PaymentPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, color: Colors.orange, size: 80),

              const SizedBox(height: 18),

              const Text(
                "Pago pendiente",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Tu cita se confirmará automáticamente\ncuando completes el pago en efectivo.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Entendido"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
