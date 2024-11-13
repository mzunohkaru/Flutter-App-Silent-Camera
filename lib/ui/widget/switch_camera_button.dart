import 'package:flutter/material.dart';

class SwitchCameraButton extends StatefulWidget {
  const SwitchCameraButton({super.key, required this.onTap});

  final Function onTap;

  @override
  State<SwitchCameraButton> createState() => _SwitchCameraButtonState();
}

class _SwitchCameraButtonState extends State<SwitchCameraButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await widget.onTap();
      },
      icon: Icon(
        Icons.replay,
        size: 35,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }
}
