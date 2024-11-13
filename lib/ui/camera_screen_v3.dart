import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import '../provider/camera_mode_provider.dart';
import 'widget/camera_preview.dart';
import 'widget/shutter_button.dart';
import 'widget/switch_camera_button.dart';
import 'widget/wating.dart';

class CameraScreenV3 extends HookConsumerWidget {
  const CameraScreenV3({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCameraMode = ref.watch(cameraModeProvider);
    final isVideoStatus = ref.watch(videoStatusProvider);

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
      }) async {
        try {
          final cameraController = CameraController(
            camera,
            ResolutionPreset.ultraHigh,
            enableAudio: false,
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
      [],
    );

    final activeImagePicker = useCallback(
      () async {
        await imagePicker.pickImage(
          source: ImageSource.gallery,
        );
      },
      [],
    );

    final takePicture = useCallback(
      () async {
        try {
          final cameraController = controller.value;
          if (cameraController == null ||
              !cameraController.value.isInitialized) {
            return;
          }

          isTakingPicture.value = true;
          await cameraController.pausePreview();

          final capturedImage = await screenshotController.captureFromWidget(
            CameraPreviewWidget(
              controller: cameraController,
              minAvailableZoom: minAvailableZoom.value,
              maxAvailableZoom: maxAvailableZoom.value,
              borderRadius: 0,
            ),
          );

          await ImageGallerySaver.saveImage(capturedImage);
          await cameraController.resumePreview();
        } catch (e) {
          debugPrint('写真撮影エラー: $e');
        } finally {
          isTakingPicture.value = false;
        }
      },
      [controller, isTakingPicture, minAvailableZoom, maxAvailableZoom],
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
      // bottomNavigationBar: const BottomNavigationBarWidget(),
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
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.abc),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                            : () {
                                ref.read(videoStatusProvider.notifier).state =
                                    !isVideoStatus;
                                print('Video');
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
