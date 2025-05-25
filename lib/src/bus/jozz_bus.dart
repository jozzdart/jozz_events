import 'dart:async';
import '../events/jozz_event.dart';

/// An interface for publishing and subscribing to domain events.
///
/// This interface defines the contract for event bus implementations,
/// allowing for dependency injection and mocking in tests.
abstract class JozzBus {
  /// Returns a stream of domain events of type T.
  ///
  /// This method filters the event stream to only include events of the specified type.
  Stream<T> on<T extends JozzEvent>();

  /// Emits event to all subscribers.
  void emit(JozzEvent event);
}
