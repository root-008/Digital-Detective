import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../core/theme/app_colors.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // --- ÜST BAŞLIK ALANI ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GÖREV MERKEZİ",
                        style: GoogleFonts.orbitron(
                          color: AppColors.textGray,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Obx(
                        () => Text(
                          "Hoş geldin, ${controller.userName.value}",
                          style: GoogleFonts.roboto(
                            color: AppColors.textWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonBlue.withOpacity(0.3),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.person, color: AppColors.neonBlue),
                      color: AppColors.cardBackground, // Menü arkaplan rengi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        if (value == 'reset') {
                          _showResetConfirmation(context);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'info',
                            enabled: false, // Tıklanamaz, sadece bilgi
                            child: Text(
                              "Ajan: ${controller.userName.value}",
                              style: const TextStyle(color: AppColors.textGray),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'reset',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: AppColors.neonRed,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Görevi Sıfırla (Çıkış)",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- GÖREV KARTLARI (GRID) ---
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ekran genişliğine göre sütun sayısını belirle
                  // Mobilde 1, Tablette 2, Web'de 3 sütun
                  int crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : (constraints.maxWidth > 600 ? 2 : 1);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    padding: const EdgeInsets.all(24),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.4, // Kartların en-boy oranı
                    children: [
                      // MODÜL 1: AI LAB
                      Obx(
                        () => _buildMissionCard(
                          id: 1,
                          title: "YZ Laboratuvarı",
                          subtitle: "Sinir ağlarını eğit ve mantığı kavra.",
                          iconData: Icons.psychology, // Beyin ikonu
                          color: AppColors.neonBlue,
                          isLocked: controller.unlockedLevel.value < 1,
                          onTap: () => controller.openModule(1),
                        ),
                      ),

                      // MODÜL 2: DEEPFAKE AVI
                      Obx(
                        () => _buildMissionCard(
                          id: 2,
                          title: "Deepfake Avı",
                          subtitle: "Sahte videoları tespit et.",
                          iconData: Icons.videocam_off, // Kamera ikonu
                          color: AppColors.neonPurple,
                          isLocked: controller.unlockedLevel.value < 2,
                          onTap: () => controller.openModule(2),
                        ),
                      ),

                      // MODÜL 3: KRİZ MASASI
                      Obx(
                        () => _buildMissionCard(
                          id: 3,
                          title: "Kriz Masası",
                          subtitle: "Etik kararlar ver ve yönet.",
                          iconData: Icons.gavel, // Terazi/Tokmak ikonu
                          color: AppColors.neonRed,
                          isLocked: controller.unlockedLevel.value < 3,
                          onTap: () => controller.openModule(3),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KART WIDGET'I ---
  Widget _buildMissionCard({
    required int id,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color color,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          // Eğer kilitli değilse kenarlık ve hafif gölge ekle
          border: isLocked
              ? Border.all(color: Colors.white10)
              : Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // İçerik
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // İkon Alanı
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.white10 : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconData,
                      size: 32,
                      color: isLocked ? AppColors.textGray : color,
                    ),
                  ),
                  const Spacer(),
                  // Başlıklar
                  Text(
                    "GÖREV 0$id",
                    style: GoogleFonts.orbitron(
                      color: isLocked
                          ? AppColors.textGray.withOpacity(0.5)
                          : color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: isLocked
                          ? AppColors.textGray
                          : AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Kilit Katmanı (Overlay)
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Karartma efekti
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        color: AppColors.textGray,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "KİLİTLİ",
                        style: GoogleFonts.orbitron(
                          color: AppColors.textGray,
                          letterSpacing: 2,
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

  void _showResetConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: "Görevi İptal Et?",
      titleStyle: GoogleFonts.orbitron(color: AppColors.textWhite, fontWeight: FontWeight.bold),
      backgroundColor: AppColors.cardBackground,
      content: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Tüm ilerlemen ve ajan kaydın silinecek. Başa dönmek istediğine emin misin?",
          style: TextStyle(color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
        onPressed: () {
          Get.back(); 
          controller.resetApp(); 
        },
        child: const Text("Evet, Sıfırla", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("İptal", style: TextStyle(color: AppColors.textWhite)),
      ),
    );
  }
}
