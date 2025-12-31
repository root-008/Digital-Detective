import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/module1_controller.dart';
import '../models/training_data_model.dart';
import '../widgets/neural_network_painter.dart';
import '../core/theme/app_colors.dart';
import '../widgets/guide_mascot.dart'; 

class Module1View extends StatelessWidget {
  final Module1Controller controller = Get.put(Module1Controller());

  Module1View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textGray),
          onPressed: () => Get.offNamed('/home'),
        ),
        title: Text(
          "GÖREV 01: KEDİ TESPİT MODELİ",
          style: GoogleFonts.orbitron(
            fontSize: 16,
            color: AppColors.neonBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
        builder: (context, constraints) {
          // Ekran genişliğine göre Responsive düzen (800px eşik değeri)
          bool isDesktop = constraints.maxWidth > 800;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isDesktop
                ? Row(
                    children: [
                      // Sol Panel: Veri Havuzu
                      Expanded(flex: 2, child: _buildDataPool()),
                      // Orta Panel: Sinir Ağı
                      Expanded(flex: 5, child: _buildNetworkArea()),
                      // Sağ Panel: İstatistikler
                      Expanded(flex: 2, child: _buildStatsPanel()),
                    ],
                  )
                : Column(
                    children: [
                      // Mobil Üst: İstatistikler
                      _buildStatsPanel(),
                      const SizedBox(height: 10),
                      // Mobil Orta: Sinir Ağı
                      Expanded(child: _buildNetworkArea()),
                      const SizedBox(height: 10),
                      // Mobil Alt: Veri Havuzu (Yatay)
                      SizedBox(
                        height: 150,
                        child: _buildDataPool(isHorizontal: true),
                      ),
                    ],
                  ),
          );
        },
      ),
      Obx(() {
            if (controller.showMascot.value) {
              return GuideMascot(
                message: controller.mascotMessage.value,
                color: controller.mascotColor.value,  
                title: controller.mascotTitle.value,  
                
                onDismiss: controller.dismissMascot,
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  /// --- 1. VERİ HAVUZU PANELİ ---
  /// Kullanıcının sürükleyeceği resimlerin listelendiği alan.
  Widget _buildDataPool({bool isHorizontal = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Yükleme Göstergesi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "VERİ SETİ",
                style: GoogleFonts.orbitron(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
              Obx(() => controller.isProcessing.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.neonBlue,
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
          const SizedBox(height: 10),
          
          // Liste
          Expanded(
            child: Obx(() {
              // Veri havuzu boşsa veya yükleniyorsa durumu yönet
              if (controller.dataPool.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.textGray));
              }

              return ListView.builder(
                scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
                itemCount: controller.dataPool.length,
                itemBuilder: (context, index) {
                  final data = controller.dataPool[index];

                  // Obx içinde Obx kullanımı: Her satırın durumu dinamik
                  return Obx(() {
                    // Animasyon sırasında sürüklemeyi engelle
                    bool disabled = controller.isProcessing.value;

                    return Opacity(
                      opacity: disabled ? 0.3 : 1.0,
                      child: IgnorePointer(
                        ignoring: disabled,
                        child: Draggable<TrainingData>(
                          data: data,
                          // Sürüklenirken parmağın altındaki görüntü
                          feedback: Opacity(
                            opacity: 0.85,
                            child: Material(
                              color: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  data.assetPath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Sürükleme başladığında asıl yerinde kalan görüntü
                          childWhenDragging: Opacity(
                            opacity: 0.2,
                            child: _buildDataItem(data),
                          ),
                          // Normal duruş
                          child: _buildDataItem(data),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Tekil Veri Kartı Görünümü
  Widget _buildDataItem(TrainingData data) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        // Veri tipine göre çerçeve rengi (Mavi: Kedi, Kırmızı: Köpek/Gürültü)
        border: Border.all(
          color: data.color.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              data.assetPath,
              width: 100, // Sabit genişlik
              height: 70, // Sabit yükseklik
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Resim bulunamazsa yedek ikon göster
                return Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              data.label,
              style: GoogleFonts.roboto(
                color: AppColors.textWhite,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// --- 2. SİNİR AĞI ALANI ---
  /// Verilerin sürüklendiği ve animasyonun oynadığı merkez alan.
  Widget _buildNetworkArea() {
    return DragTarget<TrainingData>(
      // Animasyon oynuyorsa (isProcessing = true) yeni veri kabul etme
      onWillAccept: (data) => !controller.isProcessing.value,
      
      onAccept: (data) => controller.onDataDropped(data),
      
      builder: (context, candidateData, rejectedData) {
        return Obx(() {
          // Hover Durumu: Sürüklenen veri alanın üzerine gelince parlasın
          bool isHovering = candidateData.isNotEmpty && !controller.isProcessing.value;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1218), // Çok koyu zemin
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHovering ? AppColors.neonBlue : Colors.white10,
                width: isHovering ? 2 : 1,
              ),
              boxShadow: isHovering
                  ? [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Katman 1: Dekoratif Izgara (Grid)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
                
                // Katman 2: Sinir Ağı Çizimi ve Akış Animasyonu
                Positioned.fill(
                  child: CustomPaint(
                    painter: NeuralNetworkPainter(
                      accuracy: controller.accuracy.value,
                      flowProgress: controller.flowProgress.value,
                      processingColor: controller.currentProcessingColor.value,
                    ),
                  ),
                ),

                // Katman 3: Yardımcı Metin (Başlangıçta)
                if (controller.accuracy.value < 0.15 && !controller.isProcessing.value)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        "Resimleri ağa sürükle",
                        style: GoogleFonts.roboto(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // Katman 4: İşlem Yapılıyor Bildirimi (Overlay)
                if (controller.isProcessing.value)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: controller.currentProcessingColor.value,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: controller.currentProcessingColor.value
                                .withOpacity(0.4),
                            blurRadius: 15,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: controller.currentProcessingColor.value,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "ANALİZ EDİLİYOR...",
                            style: GoogleFonts.orbitron(
                              color: controller.currentProcessingColor.value,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  /// --- 3. İSTATİSTİK PANELİ ---
  /// Modelin doğruluk oranını gösteren sağ (veya üst) panel.
  Widget _buildStatsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "MODEL DOĞRULUĞU",
            style: GoogleFonts.orbitron(
              color: AppColors.textGray,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          
          Obx(() {
            final acc = controller.accuracy.value;
            final percentage = (acc * 100).toInt();
            
            // Doğruluk oranına göre renk değişimi
            Color statusColor;
            String statusText;
            
            if (acc < 0.4) {
              statusColor = AppColors.neonRed;
              statusText = "YETERSİZ";
            } else if (acc < 0.85) {
              statusColor = AppColors.neonPurple;
              statusText = "EĞİTİLİYOR...";
            } else {
              statusColor = Colors.greenAccent;
              statusText = "HAZIR";
            }

            return Column(
              children: [
                // Yüzde Göstergesi
                Text(
                  "%$percentage",
                  style: GoogleFonts.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    shadows: [
                      Shadow(
                        color: statusColor.withOpacity(0.5),
                        blurRadius: 20,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                // İlerleme Çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: acc,
                    backgroundColor: Colors.white10,
                    color: statusColor,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Durum Metni
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.roboto(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// --- YARDIMCI SINIFLAR ---

/// Arka planda siber estetik için ince ızgara çizen painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Dikey çizgiler (Her 40 birimde bir)
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Yatay çizgiler (Her 40 birimde bir)
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}