import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/home_view.dart';
import 'package:flutter_application_1/view/intro_video_view.dart';
import 'package:flutter_application_1/view/login_view.dart';
import 'package:flutter_application_1/view/module1_view.dart';
import 'package:flutter_application_1/view/module2_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_colors.dart';

void main() async {
  // 1. GetStorage'ı başlat
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final String? savedUser = box.read('userName');

    final String startRoute = savedUser != null ? '/home' : '/';

    return GetMaterialApp(
      title: 'Dijital Dedektif',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.neonBlue,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: startRoute,
      getPages: [
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/intro-video', page: () => IntroVideoView()),
        GetPage(name: '/home', page: () => HomeView()),
        // Placeholder modüller
        GetPage(name: '/module1', page: () => Module1View()),
        GetPage(name: '/module2', page: () => Module2View()),
        GetPage(
          name: '/module3',
          page: () => const Scaffold(body: Center(child: Text("Modül 3"))),
        ),
      ],
    );
  }
}
