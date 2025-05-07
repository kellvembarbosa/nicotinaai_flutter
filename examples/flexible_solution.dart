import 'package:flutter/material.dart';

class FlexibleExample extends StatelessWidget {
  const FlexibleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flexible Solution')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.red,
              height: 100,
              width: double.infinity,
            ),
            Flexible(
              fit: FlexFit.loose, // Diferente do Expanded que usa FlexFit.tight
              child: Container(
                color: Colors.blue,
                height: MediaQuery.of(context).size.height * 0.3, // Altura proporcional à tela
                width: double.infinity,
                child: const Center(
                  child: Text('Este container tem altura flexível'),
                ),
              ),
            ),
            Container(
              color: Colors.green,
              height: 100,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}