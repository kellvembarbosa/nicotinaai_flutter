import 'package:flutter/material.dart';

class ListViewExample extends StatelessWidget {
  const ListViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulando uma lista de itens dinâmicos
    final List<String> items = List.generate(20, (index) => 'Item $index');
    
    return Scaffold(
      appBar: AppBar(title: const Text('ListView Solution')),
      body: ListView.builder(
        itemCount: items.length + 2, // +2 para os containers fixos
        itemBuilder: (context, index) {
          if (index == 0) {
            // Primeiro item fixo
            return Container(
              color: Colors.red,
              height: 100,
              width: double.infinity,
            );
          } else if (index == items.length + 1) {
            // Último item fixo
            return Container(
              color: Colors.green,
              height: 100,
              width: double.infinity,
            );
          } else {
            // Itens dinâmicos no meio
            return Container(
              color: Colors.blue.withOpacity((index - 1) / items.length),
              height: 80,
              width: double.infinity,
              child: Center(
                child: Text(items[index - 1]),
              ),
            );
          }
        },
      ),
    );
  }
}