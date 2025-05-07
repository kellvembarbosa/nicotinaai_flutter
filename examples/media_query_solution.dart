import 'package:flutter/material.dart';

class MediaQueryExample extends StatelessWidget {
  const MediaQueryExample({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculando alturas proporcionais
    final headerHeight = screenHeight * 0.15;
    final contentHeight = screenHeight * 0.6;
    final footerHeight = screenHeight * 0.15;
    
    return Scaffold(
      appBar: AppBar(title: const Text('MediaQuery Solution')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.red,
              height: headerHeight,
              width: screenWidth,
              child: const Center(
                child: Text('Cabeçalho com 15% da altura da tela'),
              ),
            ),
            Container(
              color: Colors.blue,
              height: contentHeight,
              width: screenWidth,
              child: const Center(
                child: Text('Conteúdo principal com 60% da altura da tela'),
              ),
            ),
            Container(
              color: Colors.green,
              height: footerHeight,
              width: screenWidth,
              child: const Center(
                child: Text('Rodapé com 15% da altura da tela'),
              ),
            ),
            // Conteúdo adicional para demonstrar scrolling
            ...List.generate(
              5,
              (index) => Container(
                color: Colors.amber,
                height: 100,
                width: screenWidth,
                child: Center(
                  child: Text('Conteúdo adicional $index'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}