import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'video_mode.g.dart';

@riverpod
class VideoModeNotifier extends _$VideoModeNotifier {
  @override
  bool build() {
    return true;
  }

  void play() {
    state = true;
  }

  void stop() {
    state = false;
  }
}
