import 'package:flutter/material.dart';

enum DataType { clean, noisy } 

class TrainingData {
  final String id;
  final String assetPath;
  final String label;
  final DataType type;
  final Color color;

  TrainingData({
    required this.id,
    required this.assetPath,
    required this.label,
    required this.type,
    required this.color,
  });
}