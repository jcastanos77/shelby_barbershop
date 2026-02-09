import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentErrorScreen extends StatelessWidget {
  final String message;

  const PaymentErrorScreen({
    super.key,
    this.message = "Hubo un problema con el pago",
  });

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
              const Icon(Icons.cancel, color: Colors.red, size: 80),

              const SizedBox(height: 18),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Intentar de nuevo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
