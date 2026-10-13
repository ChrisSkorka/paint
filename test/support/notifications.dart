import 'dart:async';

import 'package:flutter/foundation.dart';

Future<void> nextNotification(Listenable listenable) {
  final completer = Completer<void>();
  void notified() {
    listenable.removeListener(notified);
    completer.complete();
  }

  listenable.addListener(notified);
  return completer.future;
}
