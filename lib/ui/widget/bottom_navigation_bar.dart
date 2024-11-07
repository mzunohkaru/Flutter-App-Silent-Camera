import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/camera_mode_provider.dart';

class BottomNavigationBarWidget extends ConsumerWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(cameraModeProvider);

    return BottomNavigationBar(
      elevation: 0,
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
        ref.read(cameraModeProvider.notifier).state = index == 0;
      },
    );
  }
}
