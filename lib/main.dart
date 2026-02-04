import 'package:barbershop/PaymentSuccessScreen.dart';
import 'package:barbershop/models/PaymentErrorScreen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'PaymentPendingScreen.dart';
import 'PaymentResultPage.dart';
import 'firebase_options.dart';

import 'main_scaffold.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    FirebaseFunctions.instance.useFunctionsEmulator(
      'localhost',
      5001,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelby´s BarberShop',
      home: MainScaffold(),
      theme: ThemeData.dark(),
      routes: {
        '/payment-result': (_) => const PaymentResultPage(),
        '/payment-success': (_) => PaymentSuccessScreen(
          clientName: "",
          service: "",
        ),
        '/payment-pending': (_) => const PaymentPendingScreen(),
        '/payment-error': (_) => const PaymentErrorScreen(message: '',),
      },
    );

  }
}