import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void startMission() {
    if (formKey.currentState!.validate()) {
      // Kullanıcı adını kaydet (İlerde global state'e atılabilir)
      final userName = nameController.text;
      print("Ajan Girişi: $userName");

      // Video sayfasına yönlendir (Geçmişi silerek gitmek için offNamed)
      Get.offNamed('/intro-video'); 
    }
  }
}