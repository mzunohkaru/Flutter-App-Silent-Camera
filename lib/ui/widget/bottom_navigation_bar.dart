import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/camera_mode/camera_mode.dart';

class BottomNavigationBarWidget extends ConsumerWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(cameraModeNotifierProvider);

    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam_rounded),
          label: 'Video',
        ),
      ],
      currentIndex: selectedIndex ? 0 : 1,
      selectedItemColor: Colors.amber[800],
      onTap: (index) {
        if (index == 0) {
          ref.read(cameraModeNotifierProvider.notifier).cameraMode();
        } else {
          ref.read(cameraModeNotifierProvider.notifier).videoMode();
        }
      },
    );
  }
}
