import '../events/jozz_event.dart';
import '../bus/jozz_bus.dart';
import '../bus/jozz_bus_subscription.dart';
import '../lifecycle/jozz_lifecycle_mixin.dart';

/// Extensions for the JozzBus interface.
extension JozzBusExtensions on JozzBus {
  /// Convenience method to emit events with a fluent API.
  ///
  /// This allows chaining multiple emit calls.
  ///
  /// Example:
  /// ```dart
  /// jozzBus
  ///   .emitEvent(TodoCreatedEvent())
  ///   .emitEvent(TodoCompletedEvent());
  /// ```
  JozzBus emitEvent(JozzEvent event) {
    emit(event);
    return this;
  }

  /// Creates a subscription to events of type T.
  ///
  /// This is a convenient way to create a JozzBusSubscription, similar
  /// to Dart's Stream.listen() API.
  ///
  /// Example:
  /// ```dart
  /// _cartEventsSubscription = _eventBus.listen<ItemAddedToCartEvent>(_handleItemAddedToCart);
  /// ```
  JozzBusSubscription<T> listen<T extends JozzEvent>(void Function(T) onData) {
    return JozzBusSubscription<T>(on<T>(), onData);
  }

  /// Listen to an event and auto-register its subscription with a lifecycle-aware object.
  ///
  /// This method automatically disposes the subscription when the lifecycle owner
  /// is disposed, eliminating the need to manually track and cancel subscriptions.
  ///
  /// Example:
  /// ```dart
  /// eventBus.autoListen<InventoryUpdatedEvent>(
  ///   this, // A class with JozzLifecycleMixin (e.g., Bloc, Cubit, State)
  ///   (event) => add(ProductStockChanged(event.productId, event.newQuantity)),
  /// );
  /// ```
  JozzBusSubscription<T> autoListen<T extends JozzEvent>(JozzLifecycleMixin lifecycleOwner, void Function(T) onData) {
    final sub = listen<T>(onData);
    lifecycleOwner.addJozzSubscription(sub);
    return sub;
  }
}
