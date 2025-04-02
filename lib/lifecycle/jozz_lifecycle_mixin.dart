import 'jozz_lifecycle_handler.dart';
import '../bus/jozz_bus_subscription.dart';

/// Use this mixin in any class (e.g. Bloc, Cubit, State) to auto-clean event subscriptions.
mixin JozzLifecycleMixin {
  final JozzLifecycleHandler _jozzLifecycleHandler = JozzLifecycleHandler();

  void addJozzSubscription(JozzBusSubscription subscription) {
    _jozzLifecycleHandler.add(subscription);
  }

  void disposeJozzSubscriptions() {
    _jozzLifecycleHandler.dispose();
  }
}
