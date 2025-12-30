import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class IntroVideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Web için assets yolunu belirtiyoruz
    videoPlayerController = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..initialize().then((_) {
        isInitialized.value = true;
        videoPlayerController.play();
        videoPlayerController.setVolume(1.0); // Ses açık
      });

    // Video bitimini dinle
    videoPlayerController.addListener(checkVideoEnd);
  }

  void checkVideoEnd() {
    if (videoPlayerController.value.position == videoPlayerController.value.duration) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Video listener'ı temizle ki tekrar tetiklenmesin
    videoPlayerController.removeListener(checkVideoEnd);
    // Ana sayfaya yönlendir
    Get.offNamed('/home');
  }

  void skipVideo() {
    _navigateToHome();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}