import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  
  const NumberSelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value <= min 
              ? null 
              : () => onChanged(value - step),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[100],
            disabledForegroundColor: Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          onPressed: value >= max 
              ? null 
              : () => onChanged(value + step),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            disabledBackgroundColor: Colors.grey[100],
            disabledForegroundColor: Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
          ),
        ),
      ],
    );
  }
}