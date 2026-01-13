import 'package:flutter/material.dart';

class TimeRulerPainter extends CustomPainter {
  final DateTime startTime;
  final DateTime endTime;
  final double pixelsPerMinute;
  final List<TimeOffsetChange>
  timeZoneChanges; // List of points where offset changes

  TimeRulerPainter({
    required this.startTime,
    required this.endTime,
    required this.pixelsPerMinute,
    this.timeZoneChanges = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw lines every hour
    DateTime currentTime = startTime;
    // Align to start of hour
    if (currentTime.minute != 0) {
      currentTime = currentTime.add(Duration(minutes: 60 - currentTime.minute));
    }

    while (currentTime.isBefore(endTime)) {
      final double x = _getXForTime(currentTime);

      // Don't draw if out of bounds (optimization)
      if (x < -50 || x > size.width + 50) {
        currentTime = currentTime.add(const Duration(hours: 1));
        continue;
      }

      // Height logic: tall line for hours, short for maybe 30 mins
      final bool isMajor = currentTime.hour % 6 == 0;
      final double height = isMajor ? 20.0 : 10.0;

      // 3.3. Time Zone Fading Logic
      // Check if we are inside a transition zone
      final offsetInfo = _getOffsetAtTime(currentTime);
      double opacity = 1.0;
      DateTime displayTime = currentTime;

      if (offsetInfo.isInTransition) {
        opacity = offsetInfo.transitionOpacity;
        if (offsetInfo.useNewOffset) {
          displayTime = currentTime.add(
            Duration(hours: offsetInfo.targetOffset),
          );
        } else {
          displayTime = currentTime.add(
            Duration(hours: offsetInfo.currentOffset),
          );
        }
      } else {
        displayTime = currentTime.add(
          Duration(hours: offsetInfo.currentOffset),
        );
      }

      paint.color = Colors.grey.withOpacity(opacity);
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);

      if (isMajor) {
        textPainter.text = TextSpan(
          text: "${displayTime.hour.toString().padLeft(2, '0')}:00",
          style: TextStyle(
            color: Colors.black.withOpacity(opacity),
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, height + 2),
        );
      }

      currentTime = currentTime.add(const Duration(hours: 1));
    }
  }

  double _getXForTime(DateTime time) {
    final diff = time.difference(startTime).inMinutes;
    return diff * pixelsPerMinute;
  }

  // Simplified offset logic helper
  _OffsetInfo _getOffsetAtTime(DateTime time) {
    // Logic to find applicable timezone offset and if we are in a transition
    // For now, returning default
    return _OffsetInfo(
      currentOffset: 0,
      isInTransition: false,
      targetOffset: 0,
      transitionOpacity: 0.0,
      useNewOffset: false,
    );
  }

  @override
  bool shouldRepaint(covariant TimeRulerPainter oldDelegate) {
    return startTime != oldDelegate.startTime ||
        pixelsPerMinute != oldDelegate.pixelsPerMinute;
  }
}

class TimeOffsetChange {
  final DateTime transitionStart;
  final DateTime transitionEnd;
  final int fromOffset;
  final int toOffset;

  TimeOffsetChange(
    this.transitionStart,
    this.transitionEnd,
    this.fromOffset,
    this.toOffset,
  );
}

class _OffsetInfo {
  final int currentOffset;
  final int targetOffset;
  final bool isInTransition;
  final double transitionOpacity;
  final bool useNewOffset;

  _OffsetInfo({
    required this.currentOffset,
    this.isInTransition = false,
    required this.targetOffset,
    required this.transitionOpacity,
    required this.useNewOffset,
  });
}
