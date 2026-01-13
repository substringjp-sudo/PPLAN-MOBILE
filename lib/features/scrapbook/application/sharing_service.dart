import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/shared/data/local/repositories/scrap_repository.dart';

part 'sharing_service.g.dart';

@riverpod
class SharingService extends _$SharingService {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void build() {
    // Sharing intent is only supported on mobile platforms
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('PPLAN: SharingService skipped (Unsupported platform)');
      return;
    }

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (value) {
            if (value.isNotEmpty) {
              _handleSharedMedia(value);
            }
          },
          onError: (err) {
            debugPrint('PPLAN: getIntentDataStream error: $err');
          },
        );

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((value) {
          if (value.isNotEmpty) {
            _handleSharedMedia(value);
          }
        })
        .catchError((err) {
          debugPrint('PPLAN: getInitialMedia error: $err');
        });

    ref.onDispose(() {
      _intentDataStreamSubscription.cancel();
    });
  }

  Future<void> _handleSharedMedia(List<SharedMediaFile> value) async {
    final repo = ref.read(scrapRepositoryProvider);

    for (final media in value) {
      final scrap = Scrap()
        ..content = media.path
        ..type = _mapType(media.type)
        ..createdAt = DateTime.now()
        ..isSynced = false;

      await repo.saveScrap(scrap);
    }
  }

  ScrapType _mapType(SharedMediaType type) {
    switch (type) {
      case SharedMediaType.text:
        return ScrapType.text;
      case SharedMediaType.url:
        return ScrapType.link;
      case SharedMediaType.image:
        return ScrapType.image;
      default:
        return ScrapType.text;
    }
  }
}
