import 'package:flutter/material.dart';

class ShutterButton extends StatefulWidget {
  const ShutterButton({
    super.key,
    required this.onTap,
    this.isPerform = false,
    this.isVideoStatus = true,
  });

  final VoidCallback? onTap;
  final bool isPerform;
  final bool isVideoStatus;

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(63),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GestureDetector(
          onTap: widget.isPerform ? widget.onTap : null,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: widget.isVideoStatus ? Colors.red : Colors.white,
            child: widget.isVideoStatus
                ? const Icon(
                    Icons.pause_rounded,
                    size: 20,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
