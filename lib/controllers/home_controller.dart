import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final box = GetStorage();

  var userName = "".obs;
  var unlockedLevel = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    userName.value = box.read('userName') ?? "Ajan";
    unlockedLevel.value = box.read('unlockedLevel') ?? 1;
  }

  void openModule(int moduleId) {
    if (moduleId <= unlockedLevel.value) {
      Get.toNamed('/module$moduleId');
    } else {
      Get.snackbar(
        "Erişim Reddedildi",
        "Bu görevi açmak için önceki görevi tamamlamalısın Ajan!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF151A30),
        colorText: const Color(0xFFFF2A6D),
        margin: const EdgeInsets.all(20),
      );
    }
  }

  void unlockNextLevel() {
    if (unlockedLevel.value < 3) {
      unlockedLevel.value++;
      box.write('unlockedLevel', unlockedLevel.value);
      update();
    }
  }

  void resetApp() {
    box.erase();
    Get.offAllNamed('/');
  }
}
