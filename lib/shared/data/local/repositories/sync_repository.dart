import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/shared/data/local/collections/sync_action.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'sync_repository.g.dart';

class SyncRepository {
  final Isar _isar;
  final _uuid = const Uuid();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  SyncRepository(this._isar);

  Future<void> pushAction({
    required String collectionName,
    required String documentId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final action = SyncAction()
      ..actionId = _uuid.v4()
      ..collectionName = collectionName
      ..documentId = documentId
      ..operation = operation
      ..payloadJson = jsonEncode(payload)
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.syncActions.put(action);
    });
  }

  Future<List<SyncAction>> getPendingActions() async {
    return await _isar.syncActions
        .where()
        .isCompletedEqualTo(false)
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> markAsCompleted(String actionId) async {
    final action = await _isar.syncActions
        .where()
        .actionIdEqualTo(actionId)
        .findFirst();
    if (action != null) {
      action.isCompleted = true;
      await _isar.writeTxn(() async {
        await _isar.syncActions.put(action);
      });
    }
  }

  Future<void> logError(String actionId, String error) async {
    final action = await _isar.syncActions
        .where()
        .actionIdEqualTo(actionId)
        .findFirst();
    if (action != null) {
      action.retryCount++;
      action.lastError = error;
      await _isar.writeTxn(() async {
        await _isar.syncActions.put(action);
      });
    }
  }

  /// Processes all pending sync actions and pushes them to Firestore.
  Future<void> processPendingActions() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Sync skipped: No authenticated user.');
      return;
    }

    final pending = await getPendingActions();
    for (final action in pending) {
      try {
        await _syncToFirestore(action);
        await markAsCompleted(action.actionId);
        debugPrint('Sync success: ${action.actionId}');
      } catch (e) {
        await logError(action.actionId, e.toString());
        debugPrint('Sync failed: ${action.actionId} - $e');
      }
    }
  }

  Future<void> _syncToFirestore(SyncAction action) async {
    final docRef = _firestore
        .collection(action.collectionName)
        .doc(action.documentId);
    final data = jsonDecode(action.payloadJson) as Map<String, dynamic>;

    switch (action.operation) {
      case SyncOperation.create:
      case SyncOperation.update:
        await docRef.set(data, SetOptions(merge: true));
        break;
      case SyncOperation.delete:
        await docRef.delete();
        break;
    }
  }
}

@Riverpod(keepAlive: true)
SyncRepository syncRepository(SyncRepositoryRef ref) {
  final isar = ref.watch(isarDatabaseProvider).requireValue;
  return SyncRepository(isar);
}
