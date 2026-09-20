import 'dart:async';
import 'package:flutter/foundation.dart';

import 'core_session_controller.dart';
import 'nexabiz_session.dart';

/// Flutter [Listenable] adapter that bridges [CoreSessionController.onSessionChanged]
/// stream events to [GoRouter.refreshListenable] for real-time authentication gating.
final class CoreSessionListenable extends ChangeNotifier {
  final CoreSessionController _controller;
  late final StreamSubscription<NexaBizSession> _subscription;

  CoreSessionListenable(this._controller) {
    _subscription = _controller.onSessionChanged.listen((_) {
      notifyListeners();
    });
  }

  NexaBizSession get currentSession => _controller.currentSession;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
