import 'dart:async';

import 'package:jozz_events/jozz_events.dart';
import 'package:test/test.dart';

void main() {
  group('JozzBusService', () {
    late JozzBusService eventBus;

    setUp(() {
      eventBus = JozzBusService();
    });

    tearDown(() {
      eventBus.dispose();
    });

    test('emits events to subscribers', () async {
      // Arrange
      final event = TestEvent('Test message');
      var receivedMessage = '';

      // Act
      final completer = Completer<void>();
      final subscription = eventBus.on<TestEvent>().listen((e) {
        receivedMessage = e.message;
        completer.complete();
      });

      eventBus.emit(event);
      await completer.future;

      // Assert
      expect(receivedMessage, equals('Test message'));
      subscription.cancel();
    });

    test('filters events by type', () async {
      // Arrange
      final testEvent = TestEvent('Test message');
      final anotherEvent = AnotherTestEvent('Another message');
      var testEventCount = 0;

      final completer = Completer<void>();

      // Act
      final subscription = eventBus.on<TestEvent>().listen((_) {
        testEventCount++;
        if (testEventCount == 2) {
          completer.complete();
        }
      });

      eventBus.emit(testEvent);
      eventBus.emit(anotherEvent);
      eventBus.emit(testEvent);

      await completer.future;

      // Assert
      expect(testEventCount, equals(2));
      subscription.cancel();
    });

    test('cancels subscription properly', () async {
      // Arrange
      final event = TestEvent('Test message');
      var callCount = 0;

      final receivedCompleter = Completer<void>();

      // Act
      final subscription = eventBus.on<TestEvent>().listen((_) {
        callCount++;
        receivedCompleter.complete();
      });

      eventBus.emit(event);
      await receivedCompleter.future;
      subscription.cancel();

      // Emit again after cancellation
      eventBus.emit(event);

      // Add a small delay to ensure any incorrect handlers would have been called
      await Future.delayed(Duration(milliseconds: 50));

      // Assert
      expect(callCount, equals(1));
    });
  });
}

class TestEvent extends JozzEvent {
  final String message;
  TestEvent(this.message);
}

class AnotherTestEvent extends JozzEvent {
  final String message;
  AnotherTestEvent(this.message);
}
