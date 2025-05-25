import 'dart:async';

import 'package:test/test.dart';
import 'package:jozz_events/jozz_events.dart';

class _TestEvent extends JozzEvent {
  final String message;
  const _TestEvent(this.message);
}

void main() {
  group('Jozz Singleton', () {
    test('bus and service return the same singleton instance', () {
      final instance1 = Jozz.bus;
      final instance2 = Jozz.service;
      final instance3 = Jozz.bus;

      expect(instance1, same(instance2));
      expect(instance1, same(instance3));
    });

    test('should emit and listen to events via Jozz.bus', () async {
      final emittedEvent = _TestEvent('Hello');
      final completer = Completer<_TestEvent>();

      final sub = Jozz.bus.on<_TestEvent>().listen((event) {
        completer.complete(event);
      });

      Jozz.bus.emit(emittedEvent);

      final received = await completer.future;
      expect(received.message, equals('Hello'));

      await sub.cancel();
    });

    test('Jozz.service exposes same event stream as Jozz.bus', () async {
      final completer = Completer<String>();
      final sub = Jozz.service.on<_TestEvent>().listen((event) {
        completer.complete('ok');
      });

      Jozz.service.emit(const _TestEvent('test'));

      final result = await completer.future;
      expect(result, equals('ok'));

      await sub.cancel();
    });
  });
}
