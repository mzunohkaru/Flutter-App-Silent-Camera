import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import '../provider/camera_mode/camera_mode.dart';
import '../provider/video_mode/video_mode.dart';
import 'widget/bottom_navigation_bar.dart';
import 'widget/camera_preview.dart';
import 'widget/seekbar.dart';
import 'widget/shutter_button.dart';
import 'widget/switch_camera_button.dart';
import 'widget/wating.dart';

class CameraScreenV3 extends HookConsumerWidget {
  const CameraScreenV3({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCameraMode = ref.watch(cameraModeNotifierProvider);
    final isVideoStatus = ref.watch(videoModeNotifierProvider);

    final screenshotController = useMemoized(ScreenshotController.new);
    final imagePicker = useMemoized(ImagePicker.new);
    final cameras = useState<List<CameraDescription>>([]);
    final controller = useState<CameraController?>(null);
    final cameraLoaded = useState<bool>(false);
    final isTakingPicture = useState<bool>(false);
    final minAvailableZoom = useState<double>(1.0);
    final maxAvailableZoom = useState<double>(2.0);
    final isChangingCamera = useState<bool>(false);
    final progress = useState<double>(0.0);

    final initializeCameraController = useCallback(
      ({
        required CameraDescription camera,
        required ValueNotifier<CameraController?> controller,
        required ValueNotifier<bool> cameraLoaded,
      }) async {
        try {
          final cameraController = CameraController(
            camera,
            ResolutionPreset.high,
          );

          controller.value = cameraController;
          await cameraController.initialize();
          cameraLoaded.value = true;
        } on CameraException catch (error) {
          if (error.code == 'CameraAccessDenied') {}
          rethrow;
        }
      },
      [],
    );

    final switchCamera = useCallback(
      ({
        required List<CameraDescription> cameras,
        required CameraController currentController,
        required ValueNotifier<CameraController?> controller,
        required ValueNotifier<bool> cameraLoaded,
        required ValueNotifier<bool> isChangingCamera,
      }) async {
        final description = controller.value!.description;
        final cameraDescription = cameras.firstWhere((element) {
          final direction =
              description.lensDirection == CameraLensDirection.front
                  ? CameraLensDirection.back
                  : CameraLensDirection.front;
          return element.lensDirection == direction;
        });

        if (controller.value != null) {
          return controller.value!.setDescription(cameraDescription);
        } else {
          return initializeCameraController(
            camera: cameraDescription,
            controller: controller,
            cameraLoaded: cameraLoaded,
          );
        }
      },
      [controller.value],
    );

    final activeImagePicker = useCallback(
      () async {
        if (isCameraMode) {
          await imagePicker.pickImage(
            source: ImageSource.gallery,
          );
        } else {
          await imagePicker.pickVideo(source: ImageSource.gallery);
        }
      },
      [isCameraMode],
    );

    final takePicture = useCallback(
      () async {
        try {
          if (isTakingPicture.value) return;

          final cameraController = controller.value;

          if (cameraController == null ||
              !cameraController.value.isInitialized) {
            return;
          }
          isTakingPicture.value = true;
          progress.value = 20;
          await cameraController.pausePreview();
          progress.value = 95;
          final capturedImage = await screenshotController.captureFromWidget(
            CameraPreviewWidget(
              controller: cameraController,
              minAvailableZoom: minAvailableZoom.value,
              maxAvailableZoom: maxAvailableZoom.value,
              borderRadius: 0,
            ),
          );
          progress.value = 98;
          await ImageGallerySaver.saveImage(capturedImage);
          await cameraController.resumePreview();
          progress.value = 100;
        } catch (e) {
          debugPrint('写真撮影エラー: $e');
        } finally {
          isTakingPicture.value = false;
          progress.value = 0;
        }
      },
      [
        controller,
        isTakingPicture,
        minAvailableZoom,
        maxAvailableZoom,
        progress,
      ],
    );

    final videoRecorder = useCallback(
      () async {
        await controller.value!.startVideoRecording().then((_) {
          ref.read(videoModeNotifierProvider.notifier).play();
        });
      },
      [],
    );

    final videoStop = useCallback(
      () async {
        try {
          isTakingPicture.value = true;
          progress.value = 30;
          final file = await controller.value!.stopVideoRecording();
          if (file == null) return;
          progress.value = 90;
          await ImageGallerySaver.saveFile(file.path);
          progress.value = 100;
        } catch (e) {
          print(e);
        } finally {
          ref.read(videoModeNotifierProvider.notifier).stop();
          progress.value = 0;
          isTakingPicture.value = false;
        }
      },
      [],
    );

    useEffect(() {
      if (!isCameraMode) {
        // ビデオモードに切り替わった時のみ初期化
        controller.value?.prepareForVideoRecording();
      }
      return () async {
        if (!isCameraMode && controller.value!.value.isRecordingVideo) {
          await videoStop();
        }
      };
    }, [
      isCameraMode,
    ]);

    useEffect(
      () {
        availableCameras().then((availableCameras) {
          cameras.value = availableCameras;
          if (availableCameras.isEmpty) return;

          initializeCameraController(
            camera: availableCameras.first,
            controller: controller,
            cameraLoaded: cameraLoaded,
          );
        });

        return () {
          controller.value?.dispose();
        };
      },
      [],
    );

    if (controller.value == null || !controller.value!.value.isInitialized) {
      return const Waiting();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNavigationBarWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CameraPreviewWidget(
                controller: controller.value!,
                minAvailableZoom: minAvailableZoom.value,
                maxAvailableZoom: maxAvailableZoom.value,
              ),
              isTakingPicture.value
                  ? SeekBar(progress: progress.value)
                  : const SizedBox.shrink(),
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       IconButton(
              //         icon: const Icon(Icons.flash_on),
              //         onPressed: () {},
              //       ),
              //       IconButton(
              //         icon: const Icon(Icons.abc),
              //         onPressed: () {},
              //       ),
              //     ],
              //   ),
              // ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await activeImagePicker();
                        },
                        icon: Icon(
                          Icons.image,
                          size: 35,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      ShutterButton(
                        onTap: isCameraMode
                            ? takePicture
                            : () async {
                                if (controller.value == null) {
                                  return;
                                }

                                try {
                                  if (isVideoStatus &&
                                      controller
                                          .value!.value.isRecordingVideo) {
                                    await videoStop();
                                  } else {
                                    await videoRecorder();
                                  }
                                } on CameraException catch (e) {
                                  print(e);
                                  ref
                                      .read(videoModeNotifierProvider.notifier)
                                      .stop();
                                }
                              },
                        isPerform: cameraLoaded.value && !isTakingPicture.value,
                        isVideoStatus: isVideoStatus,
                      ),
                      SwitchCameraButton(
                        onTap: () async {
                          await switchCamera(
                            cameras: cameras.value,
                            currentController: controller.value!,
                            controller: controller,
                            cameraLoaded: cameraLoaded,
                            isChangingCamera: isChangingCamera,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
