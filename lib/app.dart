import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:silent_camera/ui/camera_screen.dart';

class App extends StatefulWidget {
  final List<CameraDescription> cameras;

  const App({super.key, required this.cameras});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: CameraScreen(cameras: widget.cameras),
    );
  }
}
