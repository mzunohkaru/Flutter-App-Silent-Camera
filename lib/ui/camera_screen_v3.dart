import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import 'widget/camera_preview.dart';
import 'widget/shutter_button.dart';

class CameraScreenV3 extends HookWidget {
  const CameraScreenV3({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenshotController = useMemoized(ScreenshotController.new);
    final imagePicker = useMemoized(ImagePicker.new);
    final cameras = useState<List<CameraDescription>>([]);
    final controller = useState<CameraController?>(null);
    final cameraLoaded = useState<bool>(false);
    final isTakingPicture = useState<bool>(false);
    final minAvailableZoom = useState<double>(1.0);
    final maxAvailableZoom = useState<double>(2.0);
    final isChangingCamera = useState<bool>(false);

    final initializeCameraController = useCallback(
      ({
        required CameraDescription camera,
        required ValueNotifier<CameraController?> controller,
        required ValueNotifier<bool> cameraLoaded,
        required BuildContext context,
      }) async {
        try {
          final cameraController = CameraController(
            camera,
            ResolutionPreset.medium,
            enableAudio: false,
          );

          controller.value = cameraController;
          await cameraController.initialize();
          cameraLoaded.value = true;
        } on CameraException catch (error) {
          if (error.code == 'CameraAccessDenied') {
            await showDialog(
              context: context,
              builder: (context) => const SimpleDialog(
                children: [Text('カメラに撮影許可を出してください')],
              ),
            );
          }
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
        required BuildContext context,
      }) async {
        if (isChangingCamera.value || cameras.isEmpty) return;

        isChangingCamera.value = true;
        try {
          final nextCamera = cameras.firstWhere(
            (camera) =>
                camera.lensDirection !=
                currentController.description.lensDirection,
          );

          await controller.value?.dispose();
          controller.value = null;

          await initializeCameraController(
            camera: nextCamera,
            controller: controller,
            cameraLoaded: cameraLoaded,
            context: context,
          );
        } catch (e) {
          debugPrint('カメラの切り替えエラー: $e');
        } finally {
          isChangingCamera.value = false;
        }
      },
      [initializeCameraController],
    );

    useEffect(
      () {
        availableCameras().then((availableCameras) {
          cameras.value = availableCameras;
          if (availableCameras.isEmpty) return;

          initializeCameraController(
            camera: availableCameras.first,
            controller: controller,
            cameraLoaded: cameraLoaded,
            context: context,
          );
        });

        return () {
          controller.value?.dispose();
        };
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<bool>(
              future:
                  cameraLoaded.value ? Future.value(true) : Future.value(false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error!}');
                } else if (!snapshot.hasData || controller.value == null) {
                  return const CircularProgressIndicator();
                }
                return CameraPreviewWidget(
                  controller: controller.value!,
                  minAvailableZoom: minAvailableZoom.value,
                  maxAvailableZoom: maxAvailableZoom.value,
                );
              },
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                      },
                      icon: const Icon(Icons.image),
                    ),
                    ShutterButton(
                      onTap: cameraLoaded.value && !isTakingPicture.value
                          ? () async {
                              final cameraController = controller.value;
                              isTakingPicture.value = true;
                              if (cameraController == null ||
                                  !cameraController.value.isInitialized) {
                                return;
                              }

                              await cameraController
                                  .pausePreview()
                                  .then((_) async {
                                await screenshotController
                                    .captureFromWidget(
                                  CameraPreviewWidget(
                                    controller: cameraController,
                                    minAvailableZoom: minAvailableZoom.value,
                                    maxAvailableZoom: maxAvailableZoom.value,
                                    borderRadius: 0,
                                  ),
                                )
                                    .then((capturedImage) async {
                                  await ImageGallerySaver.saveImage(
                                    capturedImage,
                                  );
                                });
                                await cameraController.resumePreview();
                                isTakingPicture.value = false;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      onPressed: () async {
                        await switchCamera(
                          cameras: cameras.value,
                          currentController: controller.value!,
                          controller: controller,
                          cameraLoaded: cameraLoaded,
                          isChangingCamera: isChangingCamera,
                          context: context,
                        );
                      },
                      icon: const Icon(
                        Icons.replay,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
