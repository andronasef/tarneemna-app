import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// App-wide online/offline state. Optimistic until the first check lands, so a
/// slow probe never flashes an "offline" banner on a healthy connection.
// ignore: avoid_classes_with_only_static_members
class Net {
  static final ValueNotifier<bool> online = ValueNotifier(true);
  static bool _started = false;

  /// Idempotent. onStatusChange emits once on listen, then on every change.
  static void init() {
    if (_started) return;
    _started = true;
    InternetConnectionChecker().onStatusChange.listen(
          (s) => online.value = s == InternetConnectionStatus.connected,
        );
  }
}
