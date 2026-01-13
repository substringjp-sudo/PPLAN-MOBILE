import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/timeline/domain/models/photo_model.dart';
import 'package:mobile/features/timeline/presentation/widgets/photo_thumbnail.dart';

// 4.1. Active Photo Preview
class ActivePhotoPreview extends ConsumerWidget {
  final Photo? activePhoto;

  const ActivePhotoPreview({super.key, this.activePhoto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 200, // Fixed height for top area
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.black87,
      child: activePhoto == null
          ? const Center(
              child: Text(
                'Scroll to explore your journey',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: PhotoThumbnail(assetId: activePhoto!.id, size: 120),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(activePhoto!.timestamp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activePhoto!.locationLabel ?? 'Unknown Location',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, can use intl package later
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
