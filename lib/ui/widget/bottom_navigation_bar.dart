import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BottomNavigationBarWidget extends HookWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    return BottomNavigationBar(
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
      currentIndex: selectedIndex.value,
      selectedItemColor: Colors.amber[800],
      onTap: (index) {
        selectedIndex.value = index;
      },
    );
  }
}
