import 'dart:async';

import 'package:jozz_events/jozz_events.dart';
import 'package:test/test.dart';

void main() {
  group('JozzLifecycleMixin', () {
    late JozzBusService eventBus;

    setUp(() {
      eventBus = JozzBusService();
    });

    tearDown(() {
      eventBus.dispose();
    });

    test('disposeJozzSubscriptions cancels all event subscriptions', () async {
      // Arrange
      final listener = TestFeature(eventBus);
      final event1 = TestEvent('Event 1');
      final event2 = AnotherTestEvent('Event 2');

      final completer = Completer<void>();
      listener.onBothEventsReceived = () {
        completer.complete();
      };

      // Act - emit before dispose
      eventBus.emit(event1);
      eventBus.emit(event2);
      await completer.future;

      // Assert
      expect(listener.testEventCount, equals(1));
      expect(listener.anotherEventCount, equals(1));

      // Reset the counts to verify disposal works
      listener.testEventCount = 0;
      listener.anotherEventCount = 0;

      // Act - dispose
      listener.dispose();

      // Act - emit after dispose
      eventBus.emit(event1);
      eventBus.emit(event2);

      // Add a small delay to ensure any incorrect handlers would have been called
      await Future.delayed(Duration(milliseconds: 50));

      // Assert - counts shouldn't increase
      expect(listener.testEventCount, equals(0));
      expect(listener.anotherEventCount, equals(0));
    });

    test('autoListen registers event handlers', () async {
      // Arrange
      final listener = TestFeature(eventBus);
      final event1 = TestEvent('Event 1');
      final event2 = AnotherTestEvent('Event 2');

      final completer = Completer<void>();
      listener.onBothEventsReceived = () {
        completer.complete();
      };

      // Act
      eventBus.emit(event1);
      eventBus.emit(event2);
      await completer.future;

      // Assert both event types were handled
      expect(listener.testEventCount, equals(1));
      expect(listener.anotherEventCount, equals(1));

      // Clean up
      listener.dispose();
    });

    test('multiple features with lifecycle mixin work independently', () async {
      // Arrange
      final feature1 = TestFeature(eventBus);
      final feature2 = TestFeature(eventBus);
      final event = TestEvent('Test');

      final completer1 = Completer<void>();
      final completer2 = Completer<void>();

      feature1.onTestEvent = () {
        completer1.complete();
      };

      feature2.onTestEvent = () {
        completer2.complete();
      };

      // Act
      eventBus.emit(event);

      // Wait for both features to receive the event
      await Future.wait([completer1.future, completer2.future]);

      // Assert both received the event
      expect(feature1.testEventCount, equals(1));
      expect(feature2.testEventCount, equals(1));

      // Reset feature1 counter to verify disposal works
      feature1.testEventCount = 0;

      // Act - dispose one feature
      feature1.dispose();

      // Setup new completer for feature2
      final completer3 = Completer<void>();
      feature2.onTestEvent = () {
        completer3.complete();
      };

      // Emit event again
      eventBus.emit(event);
      await completer3.future;

      // Assert - only feature2 received the second event
      expect(feature1.testEventCount, equals(0));
      expect(feature2.testEventCount, equals(2));

      // Clean up
      feature2.dispose();
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

class TestFeature with JozzLifecycleMixin {
  final JozzBus _eventBus;
  int testEventCount = 0;
  int anotherEventCount = 0;

  // Callback functions for test synchronization
  Function? onTestEvent;
  Function? onAnotherEvent;
  Function? onBothEventsReceived;

  TestFeature(this._eventBus) {
    _eventBus.autoListen<TestEvent>(this, _onTestEvent);
    _eventBus.autoListen<AnotherTestEvent>(this, _onAnotherEvent);
  }

  void _onTestEvent(TestEvent event) {
    testEventCount++;
    onTestEvent?.call();
    _checkBothEvents();
  }

  void _onAnotherEvent(AnotherTestEvent event) {
    anotherEventCount++;
    onAnotherEvent?.call();
    _checkBothEvents();
  }

  void _checkBothEvents() {
    if (testEventCount > 0 && anotherEventCount > 0) {
      onBothEventsReceived?.call();
    }
  }

  void dispose() {
    disposeJozzSubscriptions();
  }
}
