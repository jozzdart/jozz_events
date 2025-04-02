import 'package:jozz_events/jozz_events.dart';

// Step 1: Define events for different features
class AuthFeatureEvent extends JozzEvent {
  final String message;
  const AuthFeatureEvent(this.message);
}

class UserLoggedInEvent extends AuthFeatureEvent {
  final String userId;
  const UserLoggedInEvent(this.userId) : super('User logged in');
}

class UserLoggedOutEvent extends AuthFeatureEvent {
  const UserLoggedOutEvent() : super('User logged out');
}

class CartFeatureEvent extends JozzEvent {
  final String message;
  const CartFeatureEvent(this.message);
}

class ItemAddedToCartEvent extends CartFeatureEvent {
  final String productId;
  final int quantity;
  const ItemAddedToCartEvent(this.productId, this.quantity) : super('Item added to cart');
}

// Step 2: Feature modules that use the event bus
class AuthFeature {
  final JozzBus _eventBus;

  AuthFeature(this._eventBus);

  void login(String userId) {
    // Perform login logic
    print('User $userId logged in');

    // Emit event that other features can listen to
    _eventBus.emit(UserLoggedInEvent(userId));
  }

  void logout() {
    // Perform logout logic
    print('User logged out');

    // Emit event that other features can listen to
    _eventBus.emit(const UserLoggedOutEvent());
  }
}

class CartFeature {
  final JozzBus _eventBus;
  final List<JozzBusSubscription> _subscriptions = [];

  CartFeature(this._eventBus) {
    // Listen for authentication events using the extension method
    _subscriptions.add(_eventBus.listen<UserLoggedInEvent>(_onUserLoggedIn));

    _subscriptions.add(_eventBus.listen<UserLoggedOutEvent>(_onUserLoggedOut));
  }

  void _onUserLoggedIn(UserLoggedInEvent event) {
    print('Cart: Loading cart for user ${event.userId}');
  }

  void _onUserLoggedOut(UserLoggedOutEvent event) {
    print('Cart: Clearing local cart data');
  }

  void addToCart(String productId, int quantity) {
    // Add item to cart logic
    print('Adding $quantity of product $productId to cart');

    // Emit event that other features can listen to
    _eventBus.emit(ItemAddedToCartEvent(productId, quantity));
  }

  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class AnalyticsFeature with JozzLifecycleMixin {
  final JozzBus _eventBus;

  AnalyticsFeature(this._eventBus) {
    // Use the extension method that will auto-register with the lifecycle mixin
    _eventBus.autoListen<UserLoggedInEvent>(this, _trackUserLogin);
    _eventBus.autoListen<ItemAddedToCartEvent>(this, _trackAddToCart);
  }

  void _trackUserLogin(UserLoggedInEvent event) {
    print('Analytics: Tracked login for user ${event.userId}');
  }

  void _trackAddToCart(ItemAddedToCartEvent event) {
    print('Analytics: Tracked add to cart - Product ${event.productId}, Quantity: ${event.quantity}');
  }

  // Clean up subscriptions when the feature is no longer needed
  void dispose() {
    disposeJozzSubscriptions();
  }
}

void main() {
  // Create the event bus service
  final eventBus = JozzBusService();

  // Initialize features with the shared event bus
  final authFeature = AuthFeature(eventBus);
  final cartFeature = CartFeature(eventBus);
  final analyticsFeature = AnalyticsFeature(eventBus);

  // Example usage flow
  print('\n--- User login ---');
  authFeature.login('user123');

  print('\n--- Adding items to cart ---');
  cartFeature.addToCart('product456', 2);

  print('\n--- User logout ---');
  authFeature.logout();

  // Clean up
  cartFeature.dispose();
  analyticsFeature.dispose();
  eventBus.dispose();
}
