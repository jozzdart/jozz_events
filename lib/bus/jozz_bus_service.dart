import 'dart:async';

import '../bus/jozz_bus.dart';
import '../events/jozz_event.dart';

/// A service for publishing and subscribing to domain events.
///
/// The JozzBusService provides a central hub for domain event communication
/// in a clean, decoupled way. It uses a broadcast StreamController to allow
/// multiple subscribers to listen to the same event stream.
class JozzBusService implements JozzBus {
  final StreamController<JozzEvent> _controller;

  /// Creates a new JozzBusService with a broadcast StreamController.
  JozzBusService() : _controller = StreamController<JozzEvent>.broadcast();

  /// The stream of jozz events.
  ///
  /// Subscribe to this stream to receive all domain events.
  Stream<JozzEvent> get events => _controller.stream;

  @override
  Stream<T> on<T extends JozzEvent>() {
    return events.where((event) => event is T).cast<T>();
  }

  @override
  /// Emits a domain event to all subscribers.
  ///
  /// This method adds the event to the stream asynchronously.
  void emit(JozzEvent event) {
    _controller.add(event);
  }

  /// Closes the underlying StreamController.
  ///
  /// Call this method when the service is no longer needed to prevent memory leaks.
  void dispose() {
    _controller.close();
  }
}
