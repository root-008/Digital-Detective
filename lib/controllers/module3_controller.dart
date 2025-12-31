import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // YENİ
import '../models/candidate_model.dart';

class Module3Controller extends GetxController {
  // --- DURUM DEĞİŞKENLERİ ---
  var isIntroActive = true.obs; // Başlangıçta maskot var
  var isSimulationRunning = false.obs;
  var isCrisisActive = false.obs;
  var showResult = false.obs;

  var isModalHidden = false.obs;

  // --- İSTATİSTİKLER ---
  var totalProcessed = 0.obs;
  var maleHiredCount = 0.obs;
  var femaleHiredCount = 0.obs;
  
  // FL_CHART İÇİN VERİLER (X: Zaman, Y: Toplam İşe Alım Sayısı)
  var maleSpots = <FlSpot>[].obs;
  var femaleSpots = <FlSpot>[].obs;
  
  // Veri Akışı Listesi
  var recentCandidates = <Candidate>[].obs;
  var systemLogs = <String>[].obs;

  Timer? _simulationTimer;
  double _timeStep = 0; // X ekseni için zaman sayacı
  final Random _random = Random();

  // Sonuç Metinleri
  var resultHeadline = "".obs;
  var resultBody = "".obs;
  var resultColor = Colors.white.obs;

  // Maskot Mesajı
  var introMessage = "Merhaba Yönetici! Şirketin yeni İK Yapay Zeka sistemini devreye alıyoruz.\n\n"
      "Görevin: Sistemin adayları nasıl seçtiğini izlemek.\n\n"
      "Grafikleri takip et. Mavi çizgi erkekleri, pembe çizgi kadınları temsil eder. "
      "Her şeyin adil ilerlediğinden emin ol!";

  @override
  void onInit() {
    super.onInit();
    // Simülasyon hemen başlamaz, intro beklenir
  }

  // --- SİMÜLASYONU BAŞLAT ---
  void startSimulation() {
    isIntroActive.value = false;
    isSimulationRunning.value = true;
    _addLog("Sistem başlatılıyor...");
    _addLog("Algoritma v2.1 devrede...");

    // Timer süresini 1.5 saniyeye çıkardık (Daha yavaş akış)
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _timeStep++; 
      _processNewCandidate();
      
      // --- SENARYO ZAMAN ÇİZELGESİ ---
      
      // 15. Adım (Yaklaşık 22. sn): Bias Başlangıcı
      if (_timeStep == 15) {
        _addLog("UYARI: Veri setinde gizli örüntüler tespit ediliyor...");
      }

      // 25. Adım (Yaklaşık 37. sn): Kriz Derinleşiyor
      if (_timeStep == 25) {
        _addLog("DİKKAT: Cinsiyet dağılımında sapma var!");
      }

      // 30. Adım (Yaklaşık 45. sn): KRİZ ANI VE DURDURMA
      if (_timeStep >= 30 && !isCrisisActive.value) {
        _triggerCrisis();
      }
    });
  }

  void _processNewCandidate() {
    bool isMale = _random.nextBool();
    int score = 70 + _random.nextInt(30); 
    String id = "ID-${1000 + totalProcessed.value}";
    String name = isMale ? "Aday Bay_${_random.nextInt(99)}" : "Aday Bayan_${_random.nextInt(99)}";

    bool hired = false;

    // --- ALGORİTMA MANTIĞI ---
    if (_timeStep < 15) {
      // EVRE 1: ADİL DÖNEM (İlk 22 saniye)
      if (score > 80) hired = true;
    } else {
      // EVRE 2: ÖNYARGILI DÖNEM
      if (isMale) {
        if (score > 70) hired = true; // Erkekleri daha kolay al
      } else {
        if (score > 98) hired = true; // Kadınları neredeyse hiç alma
        else hired = false;
      }
    }

    totalProcessed.value++;
    if (hired) {
      if (isMale) maleHiredCount.value++;
      else femaleHiredCount.value++;
    }

    // Grafik Verisi Ekle
    // X: Zaman, Y: O anki toplam işe alım sayısı
    maleSpots.add(FlSpot(_timeStep, maleHiredCount.value.toDouble()));
    femaleSpots.add(FlSpot(_timeStep, femaleHiredCount.value.toDouble()));

    // Aday Listesine Ekle
    final candidate = Candidate(
      id: id, name: name, gender: isMale ? 'Male' : 'Female', 
      qualificationScore: score, isHired: hired
    );
    recentCandidates.insert(0, candidate);
    if (recentCandidates.length > 20) recentCandidates.removeLast();
  }

  void _triggerCrisis() {
    _simulationTimer?.cancel();
    isSimulationRunning.value = false;
    isCrisisActive.value = true;
    _addLog("KRİTİK HATA: Cinsiyet eşitsizliği sınırı aşıldı!");
    _addLog("Sistem acil durum moduna geçti. Müdahale bekleniyor.");
  }

  void _addLog(String message) {
    String timestamp = DateTime.now().toString().substring(11, 19);
    systemLogs.insert(0, "[$timestamp] $message");
  }

  void hideCrisisModal() {
    isModalHidden.value = true;
  }

  void showCrisisModal() {
    isModalHidden.value = false;
  }

  // --- KARAR VERME ---
  void makeDecision(int choiceId) {
    isCrisisActive.value = false;
    showResult.value = true;

    switch (choiceId) {
      case 1: 
        resultHeadline.value = "SKANDAL ÖNLENDİ AMA SORUN SÜRÜYOR";
        resultBody.value = "Veriler silindi ancak kök neden çözülmedi. İşe alımlar durdu.";
        resultColor.value = Colors.orangeAccent;
        break;
      case 2:
        resultHeadline.value = "TEKNOLOJİ DEVİ ESKİ USULE DÖNDÜ";
        resultBody.value = "YZ sistemi kapatıldı. Manuel inceleme çok yavaş ama daha adil.";
        resultColor.value = Colors.blueGrey;
        break;
      case 3:
        resultHeadline.value = "ŞİRKETTEN ÖRNEK DAVRANIŞ";
        resultBody.value = "Algoritma durduruldu, önyargılı veriler temizlenerek yeniden eğitildi.";
        resultColor.value = Colors.greenAccent;
        break;
    }
  }
  
  void finishGame() {
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    _simulationTimer?.cancel();
    super.onClose();
  }
}