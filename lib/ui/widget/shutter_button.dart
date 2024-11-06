import 'package:flutter/material.dart';

class ShutterButton extends StatefulWidget {
  const ShutterButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3.0),
        borderRadius: BorderRadius.circular(63),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
