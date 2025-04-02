import 'dart:async';

import 'package:jozz_events/jozz_events.dart';
import 'package:test/test.dart';

// This example demonstrates testing a more realistic application structure
// with multiple features communicating through events

void main() {
  group('ShoppingApp Integration', () {
    late AppEventBus eventBus;
    late AuthManager authManager;
    late CartManager cartManager;
    late ProductCatalog productCatalog;
    late OrderProcessor orderProcessor;

    setUp(() {
      // Set up a shared event bus for the entire application
      eventBus = AppEventBus();

      // Initialize all feature managers
      authManager = AuthManager(eventBus);
      cartManager = CartManager(eventBus);
      productCatalog = ProductCatalog(eventBus);
      orderProcessor = OrderProcessor(eventBus);
    });

    tearDown(() {
      // Clean up all features
      cartManager.dispose();
      orderProcessor.dispose();
      eventBus.dispose();
    });

    test('Complete shopping flow with events between features', () async {
      // 1. User logs in
      final loginCompleter = Completer<void>();
      cartManager.onUserLoggedIn = () {
        loginCompleter.complete();
        cartManager.onUserLoggedIn = null;
      };

      authManager.login('user123', 'password');
      await loginCompleter.future;

      // Verify cart was initialized for the user
      expect(cartManager.currentUserId, equals('user123'));
      expect(cartManager.items.isEmpty, isTrue);

      // 2. User browses products
      final product = Product('prod-1', 'Headphones', 99.99);
      productCatalog.addProduct(product);

      // 3. User adds product to cart
      final productAddedCompleter = Completer<void>();
      orderProcessor.onCartUpdated = () {
        productAddedCompleter.complete();
        orderProcessor.onCartUpdated = null;
      };

      cartManager.addToCart(product.id, 2);
      await productAddedCompleter.future;

      // Verify product was added to cart
      expect(cartManager.items.length, equals(1));
      expect(cartManager.items['prod-1'], equals(2));

      // Verify order processor was notified
      expect(orderProcessor.lastCartUpdate, isNotNull);
      expect(orderProcessor.lastCartUpdate!.items.length, equals(1));

      // 4. User checks out
      final checkoutCompleter = Completer<void>();
      authManager.onOrderPlaced = () {
        checkoutCompleter.complete();
        authManager.onOrderPlaced = null;
      };

      final orderId = orderProcessor.processOrder('user123', cartManager.getCartItems());
      await checkoutCompleter.future;

      // Clear cart after order is processed
      cartManager.clearCart();

      // Verify cart was cleared
      expect(cartManager.items.isEmpty, isTrue);

      // Verify order was added to user history
      expect(authManager.getUserOrders('user123'), contains(orderId));

      // 5. User logs out
      final logoutCompleter = Completer<void>();
      cartManager.onUserLoggedOut = () {
        logoutCompleter.complete();
        cartManager.onUserLoggedOut = null;
      };

      authManager.logout();
      await logoutCompleter.future;

      // Verify user data was cleared
      expect(cartManager.currentUserId, isNull);
    });
  });
}

// App-specific event bus (optional wrapper around JozzBusService)
class AppEventBus implements JozzBus {
  final JozzBusService _eventBus = JozzBusService();

  @override
  void emit(JozzEvent event) => _eventBus.emit(event);

  @override
  Stream<T> on<T extends JozzEvent>() => _eventBus.on<T>();

  void dispose() => _eventBus.dispose();
}

// Domain Models
class Product {
  final String id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);
}

class CartItem {
  final String productId;
  final int quantity;

  CartItem(this.productId, this.quantity);
}

class Cart {
  final String userId;
  final Map<String, int> items;

  Cart(this.userId, this.items);
}

// Domain Events
class UserLoggedInEvent extends JozzEvent {
  final String userId;
  UserLoggedInEvent(this.userId);
}

class UserLoggedOutEvent extends JozzEvent {}

class ProductAddedEvent extends JozzEvent {
  final String productId;
  ProductAddedEvent(this.productId);
}

class CartUpdatedEvent extends JozzEvent {
  final Cart cart;
  CartUpdatedEvent(this.cart);
}

class OrderPlacedEvent extends JozzEvent {
  final String orderId;
  final String userId;
  OrderPlacedEvent(this.orderId, this.userId);
}

// Feature Managers
class AuthManager {
  final JozzBus _eventBus;
  String? _currentUserId;
  final Map<String, List<String>> _userOrders = {};
  Function? onOrderPlaced;

  AuthManager(this._eventBus) {
    _eventBus.listen<OrderPlacedEvent>(_onOrderPlaced);
  }

  void login(String userId, String password) {
    // In a real app, perform authentication logic
    _currentUserId = userId;
    _eventBus.emit(UserLoggedInEvent(userId));
  }

  void logout() {
    _currentUserId = null;
    _eventBus.emit(UserLoggedOutEvent());
  }

  void _onOrderPlaced(OrderPlacedEvent event) {
    if (!_userOrders.containsKey(event.userId)) {
      _userOrders[event.userId] = [];
    }
    _userOrders[event.userId]!.add(event.orderId);
    onOrderPlaced?.call();
  }

  List<String> getUserOrders(String userId) {
    return _userOrders[userId] ?? [];
  }
}

class CartManager {
  final JozzBus _eventBus;
  final List<JozzBusSubscription> _subscriptions = [];
  String? currentUserId;
  final Map<String, int> items = {};
  Function? onUserLoggedIn;
  Function? onUserLoggedOut;

  CartManager(this._eventBus) {
    _subscriptions.add(_eventBus.listen<UserLoggedInEvent>(_onUserLoggedIn));
    _subscriptions.add(_eventBus.listen<UserLoggedOutEvent>(_onUserLoggedOut));
  }

  void _onUserLoggedIn(UserLoggedInEvent event) {
    currentUserId = event.userId;
    items.clear();
    onUserLoggedIn?.call();
  }

  void _onUserLoggedOut(UserLoggedOutEvent event) {
    currentUserId = null;
    items.clear();
    onUserLoggedOut?.call();
  }

  void addToCart(String productId, int quantity) {
    if (currentUserId == null) return;

    items[productId] = (items[productId] ?? 0) + quantity;
    _eventBus.emit(CartUpdatedEvent(Cart(currentUserId!, Map.from(items))));
  }

  void clearCart() {
    items.clear();
    if (currentUserId != null) {
      _eventBus.emit(CartUpdatedEvent(Cart(currentUserId!, {})));
    }
  }

  List<CartItem> getCartItems() {
    return items.entries.map((e) => CartItem(e.key, e.value)).toList();
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class ProductCatalog {
  final JozzBus _eventBus;
  final Map<String, Product> _products = {};

  ProductCatalog(this._eventBus);

  void addProduct(Product product) {
    _products[product.id] = product;
    _eventBus.emit(ProductAddedEvent(product.id));
  }

  Product? getProduct(String id) => _products[id];
}

class OrderProcessor with JozzLifecycleMixin {
  final JozzBus _eventBus;
  Cart? lastCartUpdate;
  int _nextOrderId = 1000;
  Function? onCartUpdated;

  OrderProcessor(this._eventBus) {
    _eventBus.autoListen<CartUpdatedEvent>(this, _onCartUpdated);
  }

  void _onCartUpdated(CartUpdatedEvent event) {
    lastCartUpdate = event.cart;
    onCartUpdated?.call();
  }

  String processOrder(String userId, List<CartItem> items) {
    // Process payment, create order, etc.
    final orderId = 'ORDER-${_nextOrderId++}';
    _eventBus.emit(OrderPlacedEvent(orderId, userId));
    return orderId;
  }

  void dispose() {
    disposeJozzSubscriptions();
  }
}
