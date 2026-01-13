import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailCacheService {
  final Map<String, Uint8List> _cache = {};

  Future<Uint8List?> getThumbnail(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    final AssetEntity? asset = await AssetEntity.fromId(id);
    if (asset == null) return null;

    final data = await asset.thumbnailData;
    if (data != null) {
      _cache[id] = data;
    }
    return data;
  }

  void clear() {
    _cache.clear();
  }
}

final thumbnailCacheServiceProvider = Provider<ThumbnailCacheService>((ref) {
  return ThumbnailCacheService();
});
