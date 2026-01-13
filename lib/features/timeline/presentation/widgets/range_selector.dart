import 'package:flutter/material.dart';

class RangeSelector extends StatelessWidget {
  final double left;
  final double width;
  final VoidCallback onCreateStay;
  final VoidCallback onCreateActivity;
  final VoidCallback onCancel;

  const RangeSelector({
    super.key,
    required this.left,
    required this.width,
    required this.onCreateStay,
    required this.onCreateActivity,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.hotel, color: Colors.blue),
                  onPressed: onCreateStay,
                  tooltip: 'Create Stay',
                ),
                IconButton(
                  icon: const Icon(Icons.directions_run, color: Colors.blue),
                  onPressed: onCreateActivity,
                  tooltip: 'Create Activity',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: onCancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
