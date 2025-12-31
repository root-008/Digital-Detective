import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:get_storage/get_storage.dart';
import '../models/video_scenario_model.dart';
import '../core/theme/app_colors.dart';
import 'home_controller.dart';

class Module2Controller extends GetxController {
  // --- Durum Değişkenleri ---
  var currentScenarioIndex = 0.obs;
  var isVideoInitialized = false.obs;

  var isIntroActive = true.obs;
  var isVideoPaused = false.obs;

  var isGameActive = false.obs;
  var showFeedback = false.obs;

  // Sayaç
  var remainingTime = 15.0.obs;
  var totalTime = 15.0;
  Timer? _timer;

  // Puan
  var score = 0.obs;
  var correctAnswers = 0;

  VideoPlayerController? videoController;
  late List<VideoScenario> scenarios;

  // Feedback
  var feedbackTitle = "".obs;
  var feedbackMessage = "".obs;
  var feedbackColor = AppColors.neonBlue.obs;
  var wasUserCorrect = false.obs;

  // Maskot Mesajı
  var introMessage =
      "Ajan! Deepfake Avı başlıyor.\n\n"
      "Ekrana gelecek videoları dikkatle izle. "
      "Göz kırpmama, dudak kayması veya bulanıklık gibi hataları yakala.\n\n"
      "Karar vermek için süren var ama dikkatli ol, süre biterse video durur!";

  @override
  void onInit() {
    super.onInit();
    _loadScenarios();
  }

  void _loadScenarios() {
    scenarios = [
      VideoScenario(
        id: '1',
        videoPath: 'videos/module2/real_vlog.mp4',
        isFake: false,
        explanation: "Doğal mimikler ve ortam sesi uyumlu.",
      ),
      VideoScenario(
        id: '2',
        videoPath: 'videos/module2/fake_lip_sync.mp4',
        isFake: true,
        explanation: "Dudak hareketleri sesle eşleşmiyor.",
      ),
      VideoScenario(
        id: '3',
        videoPath: 'videos/module2/fake_blink.mp4',
        isFake: true,
        explanation: "Göz kırpma refleksi çok yapay veya hiç yok.",
      ),
      VideoScenario(
        id: '4',
        videoPath: 'videos/module2/real_news.mp4',
        isFake: false,
        explanation: "Işık ve gölgeler fizik kurallarına uygun.",
      ),
    ];
  }

  // --- OYUNU BAŞLAT ---
  void startGame() {
    isIntroActive.value = false;
    _initializeScenario(0);
  }

  Future<void> _initializeScenario(int index) async {
    if (videoController != null) {
      await videoController!.dispose();
      videoController = null;
    }

    isVideoInitialized.value = false;
    isGameActive.value = false;
    showFeedback.value = false;
    isVideoPaused.value = false;
    remainingTime.value = totalTime;

    final scenario = scenarios[index];
    videoController = VideoPlayerController.asset(scenario.videoPath);

    try {
      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();

      isVideoInitialized.value = true;
      isGameActive.value = true;
      _startTimer();
    } catch (e) {
      print("Video Hatası: $e");
      // Hata olursa bir sonrakine geçmeyi dene
      if (currentScenarioIndex.value < scenarios.length - 1) {
        nextScenario();
      }
    }
  }

  // --- SAYAÇ ---
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value -= 0.1;
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    _timer?.cancel();
    videoController?.pause();
    isVideoPaused.value = true;
  }

  // --- VİDEOYU TEKRAR OYNAT ---
  void replayVideo() {
    if (!isVideoInitialized.value) return;

    remainingTime.value = totalTime;
    isVideoPaused.value = false;
    videoController?.seekTo(Duration.zero);
    videoController?.play();
    _startTimer();
  }

  // --- TAHMİN YAPMA (DÜZELTİLEN KISIM) ---
  void makeGuess(bool isFakeGuess) {
    // Oyun aktif değilse, video durmamışsa ve süre bitmemişse işlem yapma
    // (Kullanıcı replay modundayken veya oyun sürerken tıklayabilir)
    if (!isGameActive.value && !isVideoPaused.value && remainingTime.value > 0)
      return;

    _timer?.cancel();
    videoController?.pause();
    isGameActive.value = false; // Artık cevap verilemez

    final currentScenario = scenarios[currentScenarioIndex.value];

    // HATA BURADAYDI: `userGuess` yerine parametre olan `isFakeGuess` kullanılmalıydı.
    bool isCorrect = (isFakeGuess == currentScenario.isFake);

    wasUserCorrect.value = isCorrect;

    if (isCorrect) {
      score.value += 100;
      correctAnswers++;
      feedbackTitle.value = "DOĞRU TESPİT!";
      feedbackColor.value = Colors.greenAccent;
    } else {
      feedbackTitle.value = "YANLIŞ TESPİT";
      feedbackColor.value = AppColors.neonRed;
    }

    feedbackMessage.value = currentScenario.isFake
        ? "Bu bir DEEPFAKE! ${currentScenario.explanation}"
        : "Bu video GERÇEK. ${currentScenario.explanation}";

    showFeedback.value = true;
  }

  void nextScenario() {
    if (currentScenarioIndex.value < scenarios.length - 1) {
      currentScenarioIndex.value++;
      _initializeScenario(currentScenarioIndex.value);
    } else {
      _finishModule();
    }
  }

  void _finishModule() {
    final box = GetStorage();
    box.write('unlockedLevel', 3);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadUserData();
    }

    Get.defaultDialog(
      title: "GÖREV TAMAMLANDI",
      titleStyle: const TextStyle(
        color: AppColors.neonBlue,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppColors.cardBackground,
      content: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in,
            color: AppColors.neonBlue,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            "Toplam Skor: ${score.value}",
            style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            "$correctAnswers / ${scenarios.length} doğru",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sıradaki Görev: Etik Kriz Masası",
            style: TextStyle(color: AppColors.neonBlue),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonBlue),
        onPressed: () {
          Get.back();
          Get.offNamed('/home');
        },
        child: const Text("Merkeze Dön", style: TextStyle(color: Colors.black)),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    videoController?.dispose();
    super.onClose();
  }
}
