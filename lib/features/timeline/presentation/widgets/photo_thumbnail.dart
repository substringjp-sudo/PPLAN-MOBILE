import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:mobile/features/timeline/application/thumbnail_cache_service.dart';

class PhotoThumbnail extends ConsumerWidget {
  final String assetId;
  final double size;

  const PhotoThumbnail({super.key, required this.assetId, this.size = 50.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheService = ref.watch(thumbnailCacheServiceProvider);

    return FutureBuilder<Uint8List?>(
      future: cacheService.getThumbnail(assetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image, size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }
}
