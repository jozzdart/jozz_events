import '../bus/jozz_bus_subscription.dart';

/// A handler for managing event subscriptions with lifecycle awareness.
///
/// This class stores subscriptions and provides a method to dispose them
/// when the associated object's lifecycle ends.
class JozzLifecycleHandler {
  final List<JozzBusSubscription> _subscriptions = [];

  /// Add a subscription to be managed by this handler.
  void add(JozzBusSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Dispose all managed subscriptions.
  /// Call this method in the dispose/close method of your Bloc/Cubit/State.
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
