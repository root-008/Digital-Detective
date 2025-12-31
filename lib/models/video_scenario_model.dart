class VideoScenario {
  final String id;
  final String videoPath;
  final bool isFake; // true = Sahte, false = Gerçek
  final String explanation; // Hata açıklaması veya doğrulama mesajı

  VideoScenario({
    required this.id,
    required this.videoPath,
    required this.isFake,
    required this.explanation,
  });
}
