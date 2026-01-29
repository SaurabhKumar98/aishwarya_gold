import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const ToggleButton({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // fixed smaller width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color.fromARGB(255, 250, 236, 237) : Colors.white,
          // foregroundColor: Colors.black,
          side: BorderSide(
            color: isActive ? const Color.fromARGB(255, 150, 13, 13) : Colors.grey,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}
