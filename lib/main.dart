
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'PaymentErrorScreen.dart';
import 'PaymentResultPage.dart';
import 'PaymentSuccessScreen.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'main_scaffold.dart';
import 'package:go_router/go_router.dart';


final _router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => MainScaffold(),
    ),

    GoRoute(
      path: '/payment-result',
      builder: (_, __) => const PaymentResultPage(),
    ),

    GoRoute(
      path: '/payment-success',
      builder: (_, state) {
        final name = state.uri.queryParameters['name'] ?? '';
        final service = state.uri.queryParameters['service'] ?? '';

        return PaymentSuccessScreen(
          clientName: name,
          service: service,
        );
      },
    ),

    GoRoute(
      path: '/payment-error',
      builder: (_, state) {
        final msg = state.uri.queryParameters['msg'] ?? 'Error';
        return PaymentErrorScreen(message: msg);
      },
    ),

  ],
);
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    FirebaseFunctions.instance.useFunctionsEmulator(
      'localhost',
      5001,
    );
  }
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Shelby´s BarberShop v1',
      theme: ThemeData.dark(),
      routerConfig: _router,
    );

  }
}