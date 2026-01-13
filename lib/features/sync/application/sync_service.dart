import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/shared/data/local/collections/sync_action.dart';
import 'package:mobile/shared/data/local/repositories/sync_repository.dart';
import 'package:mobile/shared/services/connectivity_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  @override
  FutureOr<void> build() {
    // Listen for connection changes to trigger sync
    ref.listen(isConnectedProvider, (previous, next) {
      if (next == true) {
        processQueue();
      }
    });
  }

  Future<void> processQueue() async {
    final isConnected = ref.read(isConnectedProvider);
    if (!isConnected) return;

    final repository = ref.read(syncRepositoryProvider);
    final pendingActions = await repository.getPendingActions();

    if (pendingActions.isEmpty) return;

    for (final action in pendingActions) {
      try {
        await _executeAction(action);
        await repository.markAsCompleted(action.actionId);
      } catch (e) {
        await repository.logError(action.actionId, e.toString());
        // Stop processing if an action fails to maintain order
        break;
      }
    }
  }

  Future<void> _executeAction(SyncAction action) async {
    // This is where actual API/Firestore calls will happen.
    // For now, we simulate success for Phase 2.
    // In Phase 5, we'll implement actual Firebase/REST calls here.

    final payload = jsonDecode(action.payloadJson);
    debugPrint(
      'Syncing ${action.collectionName} [${action.operation}]: ${action.documentId}',
    );
    debugPrint('Payload: $payload');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Success simulation
    return;
  }
}
