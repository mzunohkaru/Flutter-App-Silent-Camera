import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({super.key, required this.progress});

  final double progress;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  @override
  Widget build(BuildContext context) {
    return CircularSeekBar(
      width: double.infinity,
      height: 250,
      progress: widget.progress,
      barWidth: 8,
      startAngle: 45,
      sweepAngle: 270,
      strokeCap: StrokeCap.butt,
      progressGradientColors: const [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
      ],
      dashWidth: 1,
      dashGap: 2,
    );
  }
}
