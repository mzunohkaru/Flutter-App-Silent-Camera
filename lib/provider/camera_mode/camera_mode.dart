import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'camera_mode.g.dart';

@riverpod
class CameraModeNotifier extends _$CameraModeNotifier {
  @override
  bool build() {
    return true;
  }

  void cameraMode() {
    state = true;
  }

  void videoMode() {
    state = false;
  }
}
