import 'dart:async';

import 'package:jozz_events/jozz_events.dart';
import 'package:test/test.dart';

void main() {
  group('JozzBus Extensions', () {
    late JozzBusService eventBus;

    setUp(() {
      eventBus = JozzBusService();
    });

    tearDown(() {
      eventBus.dispose();
    });

    test('listen extension method works correctly', () async {
      // Arrange
      final event = TestEvent('Test message');
      var receivedMessage = '';

      // Act
      final completer = Completer<void>();
      final subscription = eventBus.listen<TestEvent>((e) {
        receivedMessage = e.message;
        completer.complete();
      });

      eventBus.emit(event);
      await completer.future;

      // Assert
      expect(receivedMessage, equals('Test message'));
      subscription.cancel();
    });

    test('autoListen extension with lifecycle mixin works correctly', () async {
      // Arrange
      final event = TestEvent('Test message');
      final listener = TestLifecycleListener(eventBus);
      final completer = Completer<void>();

      // For testing, add a callback to know when the event is received
      listener.onEventReceived = () {
        completer.complete();
      };

      // Act
      eventBus.emit(event);
      await completer.future;

      // Assert
      expect(listener.receivedEvents, equals(1));

      // Clean up
      listener.dispose();

      // Act again after disposal
      eventBus.emit(event);

      // Add a small delay to ensure any incorrect handlers would have been called
      await Future.delayed(Duration(milliseconds: 50));

      // Assert subscription was properly removed
      expect(listener.receivedEvents, equals(1));
    });
  });
}

class TestEvent extends JozzEvent {
  final String message;
  TestEvent(this.message);
}

class TestLifecycleListener with JozzLifecycleMixin {
  final JozzBus _eventBus;
  int receivedEvents = 0;
  Function? onEventReceived;

  TestLifecycleListener(this._eventBus) {
    _eventBus.autoListen<TestEvent>(this, _onTestEvent);
  }

  void _onTestEvent(TestEvent event) {
    receivedEvents++;
    onEventReceived?.call();
  }

  void dispose() {
    disposeJozzSubscriptions();
  }
}
