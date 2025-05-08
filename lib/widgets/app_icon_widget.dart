import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final double size;
  final double borderRadius;

  const AppIconWidget({
    super.key,
    this.size = 80,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/app_icon/app_icon.png',
        fit: BoxFit.cover,
      ),
    );
  }
}