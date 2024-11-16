import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Waiting extends StatelessWidget {
  const Waiting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingIndicator(
          indicatorType: Indicator.ballClipRotateMultiple,
          colors: [Colors.white],
          strokeWidth: 1.5,
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.black,
        ),
      ),
    );
  }
}
