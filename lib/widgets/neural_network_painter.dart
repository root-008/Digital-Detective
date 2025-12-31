import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class NeuralNetworkPainter extends CustomPainter {
  final double accuracy; // Kalıcı ağ kalınlığı
  final double flowProgress; // 0.0 ile 1.0 arası animasyon durumu
  final Color processingColor; // Akan verinin rengi (Mavi/Kırmızı)

  NeuralNetworkPainter({
    required this.accuracy,
    required this.flowProgress,
    required this.processingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. TEMEL AĞ YAPISI (Sönük Arkaplan) ---
    // Bu kısım her zaman çizilir, modelin mevcut "zekasını" temsil eder.
    
    final Paint baseLinePaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.3 + (accuracy * 0.4))
      ..strokeWidth = 1.0 + (accuracy * 6.0)
      ..strokeCap = StrokeCap.round;

    final Paint nodePaint = Paint()
      ..color = AppColors.backgroundDark
      ..style = PaintingStyle.fill;

    final Paint nodeBorderPaint = Paint()
      ..color = AppColors.neonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Koordinatlar
    final xInput = size.width * 0.15;
    final xHidden = size.width * 0.5;
    final xOutput = size.width * 0.85;

    final layerInput = [
      Offset(xInput, size.height * 0.2),
      Offset(xInput, size.height * 0.5),
      Offset(xInput, size.height * 0.8),
    ];

    final layerHidden = [
      Offset(xHidden, size.height * 0.15),
      Offset(xHidden, size.height * 0.38),
      Offset(xHidden, size.height * 0.62),
      Offset(xHidden, size.height * 0.85),
    ];

    final layerOutput = [
      Offset(xOutput, size.height * 0.3),
      Offset(xOutput, size.height * 0.7),
    ];

    // Temel Bağlantıları Çiz (Input -> Hidden)
    for (var p1 in layerInput) {
      for (var p2 in layerHidden) {
        canvas.drawLine(p1, p2, baseLinePaint);
      }
    }
    // Temel Bağlantıları Çiz (Hidden -> Output)
    for (var p1 in layerHidden) {
      for (var p2 in layerOutput) {
        canvas.drawLine(p1, p2, baseLinePaint);
      }
    }

    // --- 2. AKTİF SİNYAL ANİMASYONU (Akış) ---
    // Sadece veri işlenirken (flowProgress > 0) çizilir.
    
    if (flowProgress > 0) {
      final Paint flowPaint = Paint()
        ..color = processingColor
        ..strokeWidth = 4.0 // Akış çizgisi daha belirgin
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4); // Neon ışıma efekti

      // EVRE 1: Input -> Hidden (Progress 0.0 ile 0.5 arası)
      if (flowProgress <= 0.5) {
        // 0.0 - 0.5 aralığını, 0.0 - 1.0 aralığına normalize et (local t)
        double t = flowProgress / 0.5; 
        
        for (var p1 in layerInput) {
          for (var p2 in layerHidden) {
            // Başlangıç noktasından (p1), hedef noktaya (p2) doğru t kadar git
            Offset targetPoint = Offset.lerp(p1, p2, t)!;
            canvas.drawLine(p1, targetPoint, flowPaint);
          }
        }
      } 
      // EVRE 2: Hidden -> Output (Progress 0.5 ile 1.0 arası)
      else {
        // Input->Hidden tamamlanmış sayılır, onları tam çiz
        for (var p1 in layerInput) {
          for (var p2 in layerHidden) {
            canvas.drawLine(p1, p2, flowPaint);
          }
        }

        // Hidden düğümlerini "aktif" renge boya
        for (var p in layerHidden) {
           canvas.drawCircle(p, 8, Paint()..color = processingColor.withOpacity(0.8));
        }

        // 0.5 - 1.0 aralığını normalize et
        double t = (flowProgress - 0.5) / 0.5;

        for (var p1 in layerHidden) {
          for (var p2 in layerOutput) {
            Offset targetPoint = Offset.lerp(p1, p2, t)!;
            canvas.drawLine(p1, targetPoint, flowPaint);
          }
        }
      }
    }

    // --- 3. DÜĞÜMLERİ ÇİZ ---
    void drawNodes(List<Offset> points) {
      for (var point in points) {
        canvas.drawCircle(point, 10, nodePaint); // Siyah iç
        canvas.drawCircle(point, 10, nodeBorderPaint); // Mavi çerçeve
      }
    }

    drawNodes(layerInput);
    if (flowProgress <= 0.5) drawNodes(layerHidden); // Hidden düğümleri animasyonun 2. yarısında zaten boyanmıştı
    drawNodes(layerOutput);
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return oldDelegate.accuracy != accuracy || 
           oldDelegate.flowProgress != flowProgress;
  }
}