import '../bus/jozz_bus.dart';
import '../bus/jozz_bus_service.dart';

/// Jozz provides global access to the event system singleton.
///
/// Use `Jozz.bus` to access the interface-based event emitter/listener.
/// Use `Jozz.service` for full control (e.g., manual `dispose()`).
///
/// Prefer dependency injection for large, modular apps.
class Jozz {
  Jozz._(); // prevent instantiation

  static final JozzBusService _service = JozzBusService();

  /// Global singleton as the interface [JozzBus] (recommended for most use cases).
  static JozzBus get bus => _service;

  /// Global singleton as the concrete [JozzBusService] (for advanced usage).
  static JozzBusService get service => _service;
}

/// DEPRECATED
///
/// Use `Jozz.` instead. JozzEvents will be removed in a future version.
///
/// - Use `Jozz.bus` to access the interface-based event emitter/listener.
/// - Use `Jozz.service` for full control (e.g., manual `dispose()`).
///
/// Prefer dependency injection for large, modular apps.
@Deprecated('Use Jozz instead. JozzEvents will be removed in a future version.')
class JozzEvents {
  JozzEvents._(); // prevent instantiation

  static final JozzBusService _service = JozzBusService();

  /// Global singleton as the interface [JozzBus] (recommended for most use cases).
  static JozzBus get bus => _service;

  /// Global singleton as the concrete [JozzBusService] (for advanced usage).
  static JozzBusService get service => _service;
}
