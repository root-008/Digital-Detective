import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../core/theme/app_colors.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 1. Katman: Arka Plan Efektleri (Neon Daireler)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPurple.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonBlue.withOpacity(0.15),
              ),
            ),
          ),

          // 2. Katman: Giriş Formu
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400, // Web ve Tablette çok genişlememesi için
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Başlık
                      Text(
                        "DİJİTAL DEDEKTİF",
                        style: GoogleFonts.orbitron(
                          color: AppColors.neonBlue,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Kimlik Doğrulama Paneli",
                        style: GoogleFonts.roboto(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Input Alanı
                      TextFormField(
                        controller: controller.nameController,
                        style: const TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          labelText: "KOD ADINIZ",
                          labelStyle: const TextStyle(color: AppColors.textGray),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.neonBlue.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          prefixIcon: const Icon(Icons.security, color: AppColors.neonBlue),
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir kod adı giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Buton
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.startMission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "GÖREVE BAŞLA",
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}