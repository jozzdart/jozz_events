import 'dart:async';

import '../events/jozz_event.dart';

/// A utility class to help manage event subscriptions.
///
/// This class wraps a StreamSubscription and provides a convenient way to
/// cancel the subscription when it's no longer needed.
class JozzBusSubscription<T extends JozzEvent> {
  /// The underlying stream subscription.
  final StreamSubscription<T> subscription;

  /// Creates a new JozzBusSubscription by listening to the provided stream.
  ///
  /// The onData callback will be called whenever an event of type T is emitted.
  JozzBusSubscription(Stream<T> stream, void Function(T) onData) : subscription = stream.listen(onData);

  /// Cancels the subscription.
  ///
  /// Call this method when the subscription is no longer needed to prevent memory leaks.
  void cancel() => subscription.cancel();
}
