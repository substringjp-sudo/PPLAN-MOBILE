import 'package:flutter/material.dart';

class TimelineLayoutDelegate extends MultiChildLayoutDelegate {
  final DateTime startTime;
  final double pixelsPerMinute;

  TimelineLayoutDelegate({
    required this.startTime,
    required this.pixelsPerMinute,
  });

  @override
  void performLayout(Size size) {
    // Layout logic for children based on their time properties
    // This requires passing time data via LayoutId or similar,
    // but typically for a timeline we might just use a Stack with Positioned widgets
    // calculated in the parent.
    // Keeping this empty for now as we will use Stack in the Screen for simplicity.
  }

  @override
  bool shouldRelayout(covariant TimelineLayoutDelegate oldDelegate) {
    return startTime != oldDelegate.startTime ||
        pixelsPerMinute != oldDelegate.pixelsPerMinute;
  }
}

class TimelineUtils {
  static double timeToPixel(
    DateTime time,
    DateTime startTime,
    double pixelsPerMinute,
  ) {
    final diff = time.difference(startTime).inMinutes;
    return diff * pixelsPerMinute;
  }

  static DateTime pixelToTime(
    double pixel,
    DateTime startTime,
    double pixelsPerMinute,
  ) {
    final minutes = pixel / pixelsPerMinute;
    return startTime.add(Duration(minutes: minutes.round()));
  }
}
