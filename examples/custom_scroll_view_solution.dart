import 'package:flutter/material.dart';

class CustomScrollViewExample extends StatelessWidget {
  const CustomScrollViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomScrollView Solution')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.red,
              height: 100,
              width: double.infinity,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: Colors.blue,
              width: double.infinity,
              child: const Center(
                child: Text('Este container preenche o espaço restante'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.green,
              height: 100,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}