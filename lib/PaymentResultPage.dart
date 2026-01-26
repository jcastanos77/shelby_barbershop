import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'PaymentSuccessScreen.dart';
import 'models/PaymentErrorScreen.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(html.window.location.href);
    final status = uri.queryParameters['status'];
    final nameClient = uri.queryParameters['clientName'];
    final service = uri.queryParameters['service'];

    if (status == 'success') {
      return PaymentSuccessScreen(clientName: nameClient ?? "", service: service ?? "");
    } else {
      return const PaymentErrorScreen(
        message: 'El pago no se completó.',
      );
    }
  }
}
