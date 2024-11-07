import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// カメラのプロバイダーを定義
final camerasProvider = FutureProvider<List<CameraDescription>>(
  (_) async => availableCameras(),
);
