import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/intro_video_view.dart';
import 'package:flutter_application_1/view/login_view.dart';
import 'package:get/get.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dijital Dedektif',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.neonBlue,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        // Varsayılan font ailesi (Google Fonts eklediysen burada belirtebilirsin)
        fontFamily: 'Roboto', 
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginView()),
        GetPage(name: '/intro-video', page: () => IntroVideoView()),
        // Henüz yapmadığımız için geçici olarak Login'e atıyor, sonra düzelteceğiz
        GetPage(name: '/home', page: () => const Scaffold(body: Center(child: Text("GÖREV MERKEZİ (Yakında)")))), 
      ],
    );
  }
}