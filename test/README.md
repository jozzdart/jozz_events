# Jozz Events Tests

This directory contains tests for the jozz_events package. The tests demonstrate the functionality of the event bus system and provide examples of how to use it in your projects.

## Test Structure

- `jozz_events_test.dart`: Tests the core functionality of the JozzBusService.
- `jozz_bus_extensions_test.dart`: Tests the extension methods that make working with the event bus easier.
- `cross_feature_events_test.dart`: Tests communication between different features using the event bus.
- `lifecycle_mixin_test.dart`: Tests the JozzLifecycleMixin that automatically handles subscription cleanup.

## Using Events Across Features

The main purpose of this package is to allow different features in your application to communicate without direct dependencies. Here's a typical usage pattern:

1. Define domain events for each feature:

```dart
// Authentication events
class UserLoggedInEvent extends JozzEvent {
  final String userId;
  const UserLoggedInEvent(this.userId);
}

// Cart events
class ItemAddedToCartEvent extends JozzEvent {
  final String productId;
  final int quantity;
  const ItemAddedToCartEvent(this.productId, this.quantity);
}
```

2. Create feature-specific modules that use the event bus:

```dart
// Auth feature
class AuthFeature {
  final JozzBus _eventBus;

  AuthFeature(this._eventBus);

  void login(String userId) {
    // Perform login logic...
    _eventBus.emit(UserLoggedInEvent(userId));
  }
}

// Cart feature
class CartFeature {
  final JozzBus _eventBus;
  final List<JozzBusSubscription> _subscriptions = [];

  CartFeature(this._eventBus) {
    // Listen for authentication events
    _subscriptions.add(_eventBus.listen<UserLoggedInEvent>(_onUserLoggedIn));
  }

  void _onUserLoggedIn(UserLoggedInEvent event) {
    // Load cart for this user...
  }

  void dispose() {
    // Cancel all subscriptions when no longer needed
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
```

3. For classes that need automatic subscription management, use the JozzLifecycleMixin:

```dart
class AnalyticsFeature with JozzLifecycleMixin {
  final JozzBus _eventBus;

  AnalyticsFeature(this._eventBus) {
    // These subscriptions will be automatically managed
    _eventBus.autoListen<UserLoggedInEvent>(this, _trackUserLogin);
    _eventBus.autoListen<ItemAddedToCartEvent>(this, _trackAddToCart);
  }

  void _trackUserLogin(UserLoggedInEvent event) {
    // Track login event...
  }

  void _trackAddToCart(ItemAddedToCartEvent event) {
    // Track add to cart event...
  }

  void dispose() {
    // Clean up all subscriptions with one call
    disposeJozzSubscriptions();
  }
}
```

4. Initialize your features with a shared event bus:

```dart
final eventBus = JozzBusService();
final authFeature = AuthFeature(eventBus);
final cartFeature = CartFeature(eventBus);
final analyticsFeature = AnalyticsFeature(eventBus);

// Now your features can communicate through events!
```

## Additional Testing Patterns

The tests in this directory also demonstrate:

1. How to test asynchronous event emission and reception
2. How to verify that events are properly filtered by type
3. How to test subscription cancellation and cleanup
4. How to ensure features are properly isolated but can still communicate
