import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/module3_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/guide_mascot.dart';

class Module3View extends StatelessWidget {
  final Module3Controller controller = Get.put(Module3Controller());

  Module3View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),

      // --- ÜST BAR ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offNamed('/home'),
        ),
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AppColors.neonBlue),
            const SizedBox(width: 10),
            Text(
              "İK ALGORİTMA DENETİM PANELİ",
              style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        actions: [
          // Sistem Durum Göstergesi (Online / Hata)
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.isCrisisActive.value
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: controller.isCrisisActive.value
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.isCrisisActive.value
                        ? Icons.warning
                        : Icons.check_circle,
                    color: controller.isCrisisActive.value
                        ? Colors.red
                        : Colors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isCrisisActive.value
                        ? "KRİTİK HATA"
                        : "SİSTEM ONLİNE",
                    style: TextStyle(
                      color: controller.isCrisisActive.value
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- ANA KATMANLAR (STACK) ---
      body: Stack(
        children: [
          // 1. DASHBOARD İÇERİĞİ (Arkada çalışan sistem)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Üst Kısım: Aday Akışı ve Grafik
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      // Sol: Canlı Aday Akışı
                      Expanded(flex: 1, child: _buildCandidateFeed()),
                      const SizedBox(width: 16),
                      // Sağ: Canlı Grafik (fl_chart)
                      Expanded(flex: 2, child: _buildLiveChart()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Alt Kısım: Sistem Logları
                Expanded(flex: 1, child: _buildSystemLogs()),
              ],
            ),
          ),

          // 2. MASKOT INTRO (Başlangıçta görünür)
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
                      onDismiss: controller.startSimulation,
                    ),
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
                        onPressed: controller.startSimulation,
                        child: Text(
                          "SİSTEMİ BAŞLAT",
                          style: GoogleFonts.orbitron(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

          // 3. KRİZ MODALI (Karar Ekranı)
          Obx(() {
            // Kriz aktifse VE kullanıcı modalı gizlememişse göster
            if (controller.isCrisisActive.value &&
                !controller.isModalHidden.value) {
              return _buildCrisisModal();
            }
            return const SizedBox.shrink();
          }),

          // 4. "KARAR PANELİNİ AÇ" BUTONU (İnceleme Modu)
          Obx(() {
            // Kriz aktifse AMA modal gizlenmişse (inceleme yapıyorsa) butonu göster
            if (controller.isCrisisActive.value &&
                controller.isModalHidden.value) {
              return Positioned(
                bottom: 30,
                right: 30,
                child: FloatingActionButton.extended(
                  onPressed: controller.showCrisisModal,
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.gavel, color: Colors.white),
                  label: Text(
                    "KARAR PANELİNİ AÇ",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 5. SONUÇ EKRANI (Gazete Manşeti)
          Obx(() {
            if (controller.showResult.value) {
              return _buildResultOverlay();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // --- BİLEŞEN 1: ADAY AKIŞ LİSTESİ ---
  Widget _buildCandidateFeed() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CANLI VERİ AKIŞI",
                  style: GoogleFonts.orbitron(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const Icon(Icons.sensors, color: Colors.green, size: 14),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.recentCandidates.length,
                itemBuilder: (context, index) {
                  final candidate = controller.recentCandidates[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      border: Border(
                        left: BorderSide(
                          color: candidate.isHired ? Colors.green : Colors.red,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.gender == 'Male' ? "ERKEK" : "KADIN",
                              style: TextStyle(
                                color: candidate.gender == 'Male'
                                    ? Colors.blueAccent
                                    : Colors.pinkAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Yetenek Puanı: ${candidate.qualificationScore}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: candidate.isHired
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            candidate.isHired ? "KABUL" : "RED",
                            style: GoogleFonts.orbitron(
                              color: candidate.isHired
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BİLEŞEN 2: CANLI GRAFİK (fl_chart) ---
  Widget _buildLiveChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "İŞE ALIM GRAFİĞİ (TÜM SÜREÇ)",
                style: GoogleFonts.orbitron(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  _legendItem(Colors.blue, "Erkek"),
                  const SizedBox(width: 10),
                  _legendItem(Colors.pinkAccent, "Kadın"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              // Grafiğin X ekseni sınırlarını belirle
              double currentX = 0;
              if (controller.maleSpots.isNotEmpty) {
                currentX = controller.maleSpots.last.x;
              }
              // Başlangıçta grafik boş görünmesin diye minimum 20 birimlik alan göster
              double visibleMaxX = currentX < 20 ? 20 : currentX;

              return LineChart(
                LineChartData(
                  // DÜZELTME 1: Grafiğin dışarı taşmasını engelle (Kırpma)
                  clipData: FlClipData.all(),

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.white10, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white10),
                  ),
                  lineBarsData: [
                    // Erkek Çizgisi
                    LineChartBarData(
                      spots: controller.maleSpots.toList(),
                      isCurved: true,
                      // Eğrinin dışarı taşmasını engellemek için preventCurveOverShooting açılabilir
                      preventCurveOverShooting: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    // Kadın Çizgisi
                    LineChartBarData(
                      spots: controller.femaleSpots.toList(),
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: Colors.pinkAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.pinkAccent.withOpacity(0.1),
                      ),
                    ),
                  ],
                  // DÜZELTME 2: Kaydırmayı kapat, tüm veriyi sığdır
                  minX: 0, // Hep en baştan başla
                  maxX: visibleMaxX, // En son veriye kadar göster (Sıkıştırır)
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  // --- BİLEŞEN 3: SİSTEM LOGLARI ---
  Widget _buildSystemLogs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "> SYSTEM_TERMINAL_V2.1",
            style: GoogleFonts.robotoMono(color: Colors.green, fontSize: 12),
          ),
          const Divider(color: Colors.green, thickness: 0.5),
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true, // Loglar alttan yukarı dolsun
                itemCount: controller.systemLogs.length,
                itemBuilder: (context, index) {
                  // Listeyi ters çevirdiğimiz için index'i düzeltmeye gerek yok,
                  // controller zaten 0. indexe ekleme yapıyor.
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      controller.systemLogs[index],
                      style: GoogleFonts.robotoMono(
                        color: Colors.greenAccent,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BİLEŞEN 4: KRİZ MODALI ---
  Widget _buildCrisisModal() {
    return Container(
      color: Colors.black87, // Arkaplanı karart
      child: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF221111), // Koyu kırmızı alarm rengi
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                "ALGORİTMİK ÖNYARGI TESPİT EDİLDİ",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sistem, eşit yetenek puanına sahip olmalarına rağmen KADIN adayları %95 oranında eliyor.\n\n"
                "Bu durum şirket politikalarına, etik kurallara ve yasalara aykırıdır.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // İNCELE BUTONU
              TextButton.icon(
                onPressed: controller.hideCrisisModal,
                icon: const Icon(Icons.analytics, color: Colors.white70),
                label: const Text(
                  "PANELİ VE GRAFİKLERİ İNCELE",
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "YÖNETİCİ OLARAK KARARINIZ NEDİR?",
                style: GoogleFonts.roboto(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 15),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _decisionButton(
                    "1. VERİLERİ SİL",
                    "Geçmişi silip görmezden gel.",
                    Colors.orange,
                    () => controller.makeDecision(1),
                  ),
                  _decisionButton(
                    "2. SİSTEMİ KAPAT",
                    "Manuel incelemeye dön.",
                    Colors.grey,
                    () => controller.makeDecision(2),
                  ),
                  _decisionButton(
                    "3. YENİDEN EĞİT",
                    "Önyargıyı temizle ve düzelt.",
                    Colors.green,
                    () => controller.makeDecision(3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decisionButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 180,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide(color: color, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- BİLEŞEN 5: SONUÇ EKRANI (GAZETE) ---
  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black, // Tüm ekranı kapla
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white, // Gazete kağıdı
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GLOBAL TEKNOLOJİ HABERLERİ",
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().substring(0, 10),
                    style: GoogleFonts.roboto(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 3),
              const SizedBox(height: 10),

              Text(
                "SON DAKİKA",
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.yellow,
                ),
              ),
              const SizedBox(height: 10),

              Obx(
                () => Text(
                  controller.resultHeadline.value,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => Text(
                  controller.resultBody.value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Georgia', // Gazete fontu
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onPressed: controller.finishGame,
                  child: const Text("ANA EKRANA DÖN VE ROZETİ AL"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
