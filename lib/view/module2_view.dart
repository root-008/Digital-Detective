import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../controllers/module2_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/guide_mascot.dart'; // Maskot widget'ını kullanacağız

class Module2View extends StatelessWidget {
  final Module2Controller controller = Get.put(Module2Controller());

  Module2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Koyu arka plan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offNamed('/home'),
        ),
        title: Text(
          "GÖREV 02: DEEPFAKE AVI",
          style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- ANA İÇERİK (TELEFON ÇERÇEVESİ) ---
          Center(
            child: _buildPhoneFrame(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Video Oynatıcı
                  Obx(() {
                    if (controller.isVideoInitialized.value &&
                        controller.videoController != null) {
                      return VideoPlayer(controller.videoController!);
                    } else {
                      return Container(
                        color: Colors.black,
                      ); // Yüklenirken siyah ekran
                    }
                  }),

                  // 2. UI Katmanı (Süre, Skor, Butonlar) - Telefonun İçinde
                  _buildInPhoneUI(),

                  // 3. Replay Butonu (Video Durunca Çıkar)
                  Obx(() {
                    if (controller.isVideoPaused.value) {
                      return Center(
                        child: GestureDetector(
                          onTap: controller.replayVideo,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 4. Sonuç (Feedback) Overlay - Telefon Ekranını Kaplar
                  Obx(() {
                    if (controller.showFeedback.value) {
                      return _buildFeedbackOverlay();
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // --- INTRO KATMANI (EN ÜSTTE) ---
          // Oyun başlamadan önce maskot çıkar, her şeyi kapatır.
          Obx(() {
            if (controller.isIntroActive.value) {
              return Container(
                color: Colors.black87, // Arkaplanı karart
                child: Stack(
                  children: [
                    GuideMascot(
                      title: "GÖREV BRİFİNGİ",
                      message: controller.introMessage,
                      color: AppColors.neonBlue,
                      onDismiss: controller
                          .startGame, // "Anlaşıldı" diyince oyun başlar
                    ),
                    // Ortaya da büyük bir Başla butonu koyalım
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: controller.startGame,
                        child: Text(
                          "ANALİZE BAŞLA",
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // --- TELEFON ÇERÇEVESİ WIDGET'I ---
  Widget _buildPhoneFrame({required Widget child}) {
    return Container(
      // Telefon Boyutları (Yaklaşık 9:16 - Responsive)
      width: Get.width > 500 ? 360 : Get.width * 0.9,
      height: Get.height > 800 ? 700 : Get.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF333333), width: 8), // Çerçeve
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22), // İç köşe yuvarlama
        child: child,
      ),
    );
  }

  // --- TELEFON İÇİNDEKİ UI ---
  Widget _buildInPhoneUI() {
    return SafeArea(
      child: Column(
        children: [
          // Üst Bar (Süre ve Skor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: controller.remainingTime.value / 15.0,
                        backgroundColor: Colors.white24,
                        color: controller.remainingTime.value > 5
                            ? AppColors.neonBlue
                            : AppColors.neonRed,
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => Text(
                    "${controller.score.value}",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(), // Ortayı boş bırak (Video görünsün)
          // Alt Butonlar (Cevap verme)
          Obx(() {
            // Eğer sonuç ekranı açıksa butonları gizle
            if (controller.showFeedback.value) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
              child: Row(
                children: [
                  // SAHTE
                  Expanded(
                    child: _decisionButton(
                      "SAHTE",
                      AppColors.neonRed,
                      Icons.close,
                      () => controller.makeGuess(true),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // GERÇEK
                  Expanded(
                    child: _decisionButton(
                      "GERÇEK",
                      Colors.greenAccent,
                      Icons.check,
                      () => controller.makeGuess(false),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _decisionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            Text(
              text,
              style: GoogleFonts.orbitron(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SONUÇ EKRANI (OVERLAY) ---
  Widget _buildFeedbackOverlay() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.wasUserCorrect.value
                ? Icons.check_circle
                : Icons.warning,
            size: 60,
            color: controller.feedbackColor.value,
          ),
          const SizedBox(height: 15),
          Text(
            controller.feedbackTitle.value,
            style: GoogleFonts.orbitron(
              color: controller.feedbackColor.value,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            controller.feedbackMessage.value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.feedbackColor.value,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: controller.nextScenario,
              child: const Text(
                "DEVAM ET",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
