import '../bus/jozz_bus.dart';
import '../bus/jozz_bus_service.dart';

/// JozzEvents provides global access to the event system singleton.
///
/// Use `JozzEvents.bus` to access the interface-based event emitter/listener.
/// Use `JozzEvents.service` for full control (e.g., manual `dispose()`).
///
/// Prefer dependency injection for large, modular apps.
class JozzEvents {
  JozzEvents._(); // prevent instantiation

  static final JozzBusService _service = JozzBusService();

  /// Global singleton as the interface [JozzBus] (recommended for most use cases).
  static JozzBus get bus => _service;

  /// Global singleton as the concrete [JozzBusService] (for advanced usage).
  static JozzBusService get service => _service;
}
