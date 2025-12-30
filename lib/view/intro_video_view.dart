import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/intro_video_controller.dart';
import '../core/theme/app_colors.dart';

class IntroVideoView extends StatelessWidget {
  final IntroVideoController controller = Get.put(IntroVideoController());

  IntroVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sinematik etki için siyah
      body: Stack(
        children: [
          // Video Oynatıcı
          Center(
            child: Obx(() {
              if (controller.isInitialized.value) {
                return AspectRatio(
                  aspectRatio: controller.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(controller.videoPlayerController),
                );
              } else {
                return const CircularProgressIndicator(
                  color: AppColors.neonBlue,
                );
              }
            }),
          ),

          // "Atla" Butonu (Sağ Üst - Opsiyonel)
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: controller.skipVideo,
              child: Text(
                "ATLA >>",
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}