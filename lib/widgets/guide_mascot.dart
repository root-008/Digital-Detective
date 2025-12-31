import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class GuideMascot extends StatefulWidget {
  final String message;
  final String title; // Başlık (İPUCU, HATA vb.)
  final Color color; // Dinamik Renk
  final VoidCallback onDismiss;

  const GuideMascot({
    super.key,
    required this.message,
    this.title = "İPUCU",
    this.color = AppColors.neonBlue, // Varsayılan Mavi
    required this.onDismiss,
  });

  @override
  State<GuideMascot> createState() => _GuideMascotState();
}

class _GuideMascotState extends State<GuideMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxBubbleWidth = screenWidth > 800 ? 400 : screenWidth * 0.85;

    return Positioned(
      bottom: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- KONUŞMA BALONU ---
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(0),
                    ),
                    // DİNAMİK RENK: Border
                    border: Border.all(color: widget.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        // DİNAMİK RENK: Gölge
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık (Dinamik)
                      Text(
                        widget.title, // "HATA:", "BAŞARILI:" vb.
                        style: GoogleFonts.orbitron(
                          color: widget.color, // DİNAMİK RENK
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 12),
                      // Buton
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _close,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(
                                0.2,
                              ), // DİNAMİK RENK
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.color,
                              ), // DİNAMİK RENK
                            ),
                            child: Text(
                              "ANLAŞILDI",
                              style: TextStyle(
                                color: widget.color, // DİNAMİK RENK
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- MASKOT İKONU ---
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  // DİNAMİK RENK: İkon Çerçevesi
                  border: Border.all(color: widget.color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
