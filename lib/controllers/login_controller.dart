import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void startMission() {
    if (formKey.currentState!.validate()) {
      final userName = nameController.text;

      box.write('userName', userName);

      if (box.read('unlockedLevel') == null) {
        box.write('unlockedLevel', 1);
      }

      Get.offNamed('/intro-video');
    }
  }
}
