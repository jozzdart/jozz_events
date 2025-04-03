import 'dart:async';

import 'package:test/test.dart';
import 'package:jozz_events/jozz_events.dart';

class _TestEvent extends JozzEvent {
  final String message;
  const _TestEvent(this.message);
}

void main() {
  group('JozzEvents Singleton', () {
    test('bus and service return the same singleton instance', () {
      final instance1 = JozzEvents.bus;
      final instance2 = JozzEvents.service;
      final instance3 = JozzEvents.bus;

      expect(instance1, same(instance2));
      expect(instance1, same(instance3));
    });

    test('should emit and listen to events via JozzEvents.bus', () async {
      final emittedEvent = _TestEvent('Hello');
      final completer = Completer<_TestEvent>();

      final sub = JozzEvents.bus.on<_TestEvent>().listen((event) {
        completer.complete(event);
      });

      JozzEvents.bus.emit(emittedEvent);

      final received = await completer.future;
      expect(received.message, equals('Hello'));

      await sub.cancel();
    });

    test('JozzEvents.service exposes same event stream as JozzEvents.bus', () async {
      final completer = Completer<String>();
      final sub = JozzEvents.service.on<_TestEvent>().listen((event) {
        completer.complete('ok');
      });

      JozzEvents.service.emit(const _TestEvent('test'));

      final result = await completer.future;
      expect(result, equals('ok'));

      await sub.cancel();
    });
  });
}
