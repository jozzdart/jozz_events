import 'dart:async';

import 'package:jozz_events/jozz_events.dart';
import 'package:test/test.dart';

void main() {
  group('Cross-Feature Event Communication', () {
    late JozzBusService eventBus;
    late AuthFeature authFeature;
    late CartFeature cartFeature;
    late AnalyticsFeature analyticsFeature;

    setUp(() {
      eventBus = JozzBusService();
      authFeature = AuthFeature(eventBus);
      cartFeature = CartFeature(eventBus);
      analyticsFeature = AnalyticsFeature(eventBus);
    });

    tearDown(() {
      cartFeature.dispose();
      analyticsFeature.dispose();
      eventBus.dispose();
    });

    test('AuthFeature events are received by other features', () async {
      // Arrange
      final completer = Completer<void>();
      cartFeature.onUserLoggedIn = () {
        completer.complete();
      };

      // Act
      authFeature.login('user123');
      await completer.future;

      // Assert
      expect(cartFeature.loggedInUser, equals('user123'));
      expect(analyticsFeature.trackedLogins.contains('user123'), isTrue);
    });

    test('CartFeature events are received by other features', () async {
      // Arrange
      final completer = Completer<void>();
      analyticsFeature.onProductTracked = () {
        completer.complete();
      };

      // Act
      cartFeature.addToCart('product456', 2);
      await completer.future;

      // Assert
      expect(analyticsFeature.trackedProducts.contains('product456'), isTrue);
    });

    test('AuthFeature logout events trigger CartFeature cleanup', () async {
      // Arrange - login and add to cart
      final loginCompleter = Completer<void>();
      cartFeature.onUserLoggedIn = () {
        loginCompleter.complete();
      };
      authFeature.login('user123');
      await loginCompleter.future;

      cartFeature.addToCart('product456', 2);

      // Assert pre-conditions
      expect(cartFeature.cartItems.length, equals(1));

      // Arrange for logout
      final logoutCompleter = Completer<void>();
      cartFeature.onUserLoggedOut = () {
        logoutCompleter.complete();
      };

      // Act
      authFeature.logout();
      await logoutCompleter.future;

      // Assert cart was cleared
      expect(cartFeature.cartItems.isEmpty, isTrue);
      expect(cartFeature.loggedInUser, isNull);
    });

    test('Disposing features stops event reception', () async {
      // Arrange
      final loginCompleter = Completer<void>();
      cartFeature.onUserLoggedIn = () {
        loginCompleter.complete();
      };

      authFeature.login('user123');
      await loginCompleter.future;
      expect(cartFeature.loggedInUser, equals('user123'));

      // Act
      cartFeature.dispose();

      // Login again with different user
      authFeature.login('user456');

      // Add a small delay to ensure any incorrect handlers would have been called
      await Future.delayed(Duration(milliseconds: 50));

      // Assert that the cart feature didn't receive the second login
      expect(
          cartFeature.loggedInUser, equals('user123')); // Still the old value
    });
  });
}

// Feature-specific events
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
  const ItemAddedToCartEvent(this.productId, this.quantity)
      : super('Item added to cart');
}

// Feature implementations for testing
class AuthFeature {
  final JozzBus _eventBus;

  AuthFeature(this._eventBus);

  void login(String userId) {
    _eventBus.emit(UserLoggedInEvent(userId));
  }

  void logout() {
    _eventBus.emit(const UserLoggedOutEvent());
  }
}

class CartFeature {
  final JozzBus _eventBus;
  final List<JozzBusSubscription> _subscriptions = [];
  final Map<String, int> cartItems = {};
  String? loggedInUser;
  Function? onUserLoggedIn;
  Function? onUserLoggedOut;

  CartFeature(this._eventBus) {
    _subscriptions.add(_eventBus.listen<UserLoggedInEvent>(_onUserLoggedIn));
    _subscriptions.add(_eventBus.listen<UserLoggedOutEvent>(_onUserLoggedOut));
  }

  void _onUserLoggedIn(UserLoggedInEvent event) {
    loggedInUser = event.userId;
    onUserLoggedIn?.call();
  }

  void _onUserLoggedOut(UserLoggedOutEvent event) {
    loggedInUser = null;
    cartItems.clear();
    onUserLoggedOut?.call();
  }

  void addToCart(String productId, int quantity) {
    cartItems[productId] = (cartItems[productId] ?? 0) + quantity;
    _eventBus.emit(ItemAddedToCartEvent(productId, quantity));
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class AnalyticsFeature with JozzLifecycleMixin {
  final JozzBus _eventBus;
  final List<String> trackedLogins = [];
  final List<String> trackedProducts = [];
  Function? onProductTracked;

  AnalyticsFeature(this._eventBus) {
    _eventBus.autoListen<UserLoggedInEvent>(this, _trackUserLogin);
    _eventBus.autoListen<ItemAddedToCartEvent>(this, _trackAddToCart);
  }

  void _trackUserLogin(UserLoggedInEvent event) {
    trackedLogins.add(event.userId);
  }

  void _trackAddToCart(ItemAddedToCartEvent event) {
    trackedProducts.add(event.productId);
    onProductTracked?.call();
  }

  void dispose() {
    disposeJozzSubscriptions();
  }
}
