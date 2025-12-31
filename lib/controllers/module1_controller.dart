import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/training_data_model.dart';
import '../core/theme/app_colors.dart';
import 'home_controller.dart';

enum MascotMood { neutral, success, error }

class Module1Controller extends GetxController {
  // --- Durum Değişkenleri ---
  var accuracy = 0.10.obs;
  var isProcessing = false.obs;
  var flowProgress = 0.0.obs;
  var currentProcessingColor = Colors.transparent.obs;
  var completed = false.obs;

  var dataPool = <TrainingData>[].obs;

  // --- MASKOT YÖNETİMİ ---
  var showMascot = true.obs; // Maskot görünür mü?
  var mascotMessage = "".obs; // Maskot ne diyor?

  var mascotColor = AppColors.neonBlue.obs;
  var mascotTitle = "İPUCU:".obs;

  @override
  void onInit() {
    super.onInit();
    // Başlangıç (Tutorial) Mesajı
    updateMascotMessage(
      "Ajan! Biz sadece KEDİLERİ arıyoruz.\n\n"
      "Sinir ağına Kedi resimlerini sürükle. Köpekler modeli şaşırtır!",
      mood: MascotMood.neutral,
    );
    _generateLevelData();
  }

  void updateMascotMessage(
    String message, {
    MascotMood mood = MascotMood.neutral,
  }) {
    mascotMessage.value = message;
    showMascot.value = true;

    // Mood'a göre renk ve başlık seçimi
    switch (mood) {
      case MascotMood.error:
        mascotColor.value = AppColors.neonRed; // KIRMIZI
        mascotTitle.value = "HATA TESPİT EDİLDİ:";
        break;
      case MascotMood.success:
        mascotColor.value = Colors.greenAccent; // YEŞİL
        mascotTitle.value = "BAŞARILI:";
        break;
      case MascotMood.neutral:
        mascotColor.value = AppColors.neonBlue; // MAVİ
        mascotTitle.value = "İPUCU:";
        break;
    }
  }

  // Maskotu kapatma
  void dismissMascot() {
    showMascot.value = false;
  }

  void _generateLevelData() {
    dataPool.clear();
    List<TrainingData> tempList = [];

    // 1. KEDİLER
    for (int i = 1; i <= 10; i++) {
      tempList.add(
        TrainingData(
          id: 'cat_$i',
          assetPath: 'images/module1/cat$i.jpg',
          label: 'Kedi #$i',
          type: DataType.clean,
          color: AppColors.neonBlue,
        ),
      );
    }

    // 2. KÖPEKLER
    for (int i = 1; i <= 10; i++) {
      tempList.add(
        TrainingData(
          id: 'dog_$i',
          assetPath: 'images/module1/dog$i.jpg',
          label: 'Köpek #$i',
          type: DataType.noisy,
          color: AppColors.neonRed,
        ),
      );
    }

    tempList.shuffle();
    dataPool.addAll(tempList);
  }

  // --- Veri Bırakıldığında ---
  void onDataDropped(TrainingData data) async {
    if (completed.value || isProcessing.value) return;

    // Maskotu işlem sırasında gizleyebiliriz veya açık tutabiliriz.
    // Şimdilik odak dağılmaması için işlem bitene kadar bekletelim.

    isProcessing.value = true;
    currentProcessingColor.value = data.type == DataType.clean
        ? AppColors.neonBlue
        : AppColors.neonRed;
    flowProgress.value = 0.0;

    for (double i = 0; i <= 1.0; i += 0.02) {
      await Future.delayed(const Duration(milliseconds: 20));
      flowProgress.value = i;
    }

    // --- SNACKBAR YERİNE MASKOT ---
    if (data.type == DataType.clean) {
      // DOĞRU HAMLE
      accuracy.value += 0.15;
      if (accuracy.value > 1.0) accuracy.value = 1.0;

      // Maskot Mutlu Mesaj
      updateMascotMessage(
        "Harika! Bu bir kedi verisi. Model öğreniyor.",
        mood: MascotMood.success,
      );
    } else {
      // YANLIŞ HAMLE
      accuracy.value -= 0.10;
      if (accuracy.value < 0.0) accuracy.value = 0.0;

      // Maskot Uyarı Mesajı
      updateMascotMessage(
        "Dikkat Ajan! Bu bir KEDİ DEĞİL. Yanlış veri modeli bozar!",
        mood: MascotMood.error,
      );
    }

    // Veriyi havuzdan sil (İsteğe bağlı, ekran temizlenir)
    dataPool.remove(data);

    flowProgress.value = 0.0;
    isProcessing.value = false;
    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (accuracy.value >= 0.85 && !completed.value) {
      completed.value = true;
      _unlockNextLevel();

      // Başarı durumunda maskot final konuşması yapsın (Dialog yerine de geçebilir)
      // Ancak User Flow'da Dialog olduğu için onu koruyoruz, maskotu gizliyoruz.
      showMascot.value = false;
      _showSuccessDialog();
    }
  }

  void _unlockNextLevel() {
    final box = GetStorage();
    int currentUnlock = box.read('unlockedLevel') ?? 1;
    if (currentUnlock < 2) {
      box.write('unlockedLevel', 2);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadUserData();
      }
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors
            .transparent, // Arkaplanı şeffaf yapıp özel tasarım kullanacağız
        child: Container(
          width: 500, // Genişliği sınırla (Web için çok yayılmasın)
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonBlue.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            children: [
              // --- 1. MASKOT VE BAŞLIK ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.greenAccent,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "GÖREV TAMAMLANDI!",
                style: GoogleFonts.orbitron(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // --- 2. "BİZ NE YAPTIK?" BÖLÜMÜ ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rapor Özeti:",
                  style: GoogleFonts.roboto(
                    color: AppColors.neonBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: "Harika iş çıkardın Ajan! Az önce yaptığın şeye ",
                    ),
                    TextSpan(
                      text: "Denetimli Öğrenme (Supervised Learning)",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: " denir.\n\n"),

                    const TextSpan(text: "🤖 "),
                    TextSpan(
                      text: "Yapay Zeka neyi bilmiyordu? ",
                      style: GoogleFonts.roboto(
                        color: AppColors.neonBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          "Başlangıçta modelin 'Kedi'nin ne olduğunu bilmiyordu.\n",
                    ),

                    const TextSpan(text: "✅ "),
                    TextSpan(
                      text: "Sen ne yaptın? ",
                      style: GoogleFonts.roboto(
                        color: AppColors.neonBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          "Ona doğru örnekleri (Temiz Veri) gösterip, yanlışları (Köpekler/Gürültü) eledin. ",
                    ),
                    const TextSpan(
                      text:
                          "Böylece sinir ağları desenleri tanımayı öğrendi.\n\n",
                    ),

                    const TextSpan(
                      text:
                          "Bu model artık eğitildi ve göreve hazır. Şimdi bu teknolojiyi kullanarak sahte videoları yakalama zamanı!",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. AKSİYON BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Get.back(); // Dialogu kapat
                    Get.offNamed('/home'); // Ana merkeze dön
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SIRADAKİ GÖREV: DEEPFAKE",
                        style: GoogleFonts.orbitron(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible:
          false, // Kullanıcı boşluğa basıp kapatamasın, butona basmak zorunda
    );
  }
}
