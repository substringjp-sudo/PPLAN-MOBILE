import 'package:flutter/material.dart';
import 'package:mobile/features/timeline/domain/models/photo_model.dart';

// 4.2. Timeline Slider - Photo Zone with Location-Aware Coloring
class PhotoZoneBar extends StatelessWidget {
  final Photo photo;
  final bool isHighlighted;

  const PhotoZoneBar({
    super.key,
    required this.photo,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // 3.1. Location-Aware Coloring Rendering
    // Hue 0-360 mapped to HSVColor
    final Color barColor = HSVColor.fromAHSV(
      1.0,
      photo.hue ?? 0.0,
      0.8, // Saturation
      0.9, // Value
    ).toColor();

    return Container(
      width: 4.0, // Fixed width per photo tick, or variable based on zoom
      height: isHighlighted ? 60.0 : 40.0, // Expand if near center
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}
