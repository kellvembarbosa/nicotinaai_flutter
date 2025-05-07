import 'package:flutter/material.dart';

class IntrinsicHeightExample extends StatelessWidget {
  const IntrinsicHeightExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IntrinsicHeight Solution')),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            children: [
              Container(
                color: Colors.red,
                height: 100,
                width: double.infinity,
              ),
              Expanded(
                child: Container(
                  color: Colors.blue,
                  width: double.infinity,
                  child: const Center(
                    child: Text('Este container irá expandir'),
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
      ),
    );
  }
}