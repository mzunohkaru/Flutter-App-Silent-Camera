import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Thumbnail extends StatefulWidget {
  const Thumbnail(
      {super.key, required this.videoController, required this.imageFile});

  final VideoPlayerController videoController;
  final File imageFile;

  @override
  State<Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 64.0,
              height: 64.0,
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.pink)),
                child: Center(
                  child: AspectRatio(
                      aspectRatio: widget.videoController.value.aspectRatio,
                      child: VideoPlayer(widget.videoController)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
