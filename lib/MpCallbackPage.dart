import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MpCallbackPage extends StatefulWidget {
  const MpCallbackPage({super.key});

  @override
  State<MpCallbackPage> createState() => _MpCallbackPageState();
}

class _MpCallbackPageState extends State<MpCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handle();
  }

  Future<void> _handle() async {
    final uri = Uri.base;

    final code = uri.queryParameters['code'];
    final uid = uri.queryParameters['state'];

    if (code == null || uid == null) {
      Navigator.pop(context);
      return;
    }

    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('exchangeMpCode');

      await callable.call({
        'code': code,
        'uid': uid,
      });

      Navigator.pop(context); // regresa dashboard
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
