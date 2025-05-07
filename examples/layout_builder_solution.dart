import 'package:flutter/material.dart';

class LayoutBuilderExample extends StatelessWidget {
  const LayoutBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LayoutBuilder Solution')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.red,
                    height: 100,
                    width: double.infinity,
                  ),
                  Flexible(
                    child: Container(
                      color: Colors.blue,
                      width: double.infinity,
                      height: 200, // altura mínima
                      child: const Center(
                        child: Text('Este container é flexível'),
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
        },
      ),
    );
  }
}