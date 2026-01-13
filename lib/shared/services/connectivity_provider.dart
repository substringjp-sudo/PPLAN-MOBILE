import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivity(ConnectivityRef ref) {
  return Connectivity().onConnectivityChanged;
}

@Riverpod(keepAlive: true)
bool isConnected(IsConnectedRef ref) {
  final connectivity = ref.watch(connectivityProvider).valueOrNull;
  if (connectivity == null) return false;

  return !connectivity.contains(ConnectivityResult.none);
}
