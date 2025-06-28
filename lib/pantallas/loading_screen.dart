import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? mensaje;
  const LoadingScreen({Key? key, this.mensaje}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            if (mensaje != null) ...[
              const SizedBox(height: 16),
              Text(mensaje!, style: const TextStyle(fontSize: 16)),
            ]
          ],
        ),
      ),
    );
  }
}