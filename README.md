# 📦 jozz_events

> **Domain-first, framework-agnostic event system built for Clean Architecture**

**`jozz_events`** is a lightweight, strongly-typed event management system designed to enable clean, decoupled communication between features in large-scale applications.

Inspired by domain-driven design and separation of concerns, it enables features to react to domain events **without knowing about each other**, making it a perfect fit for **Clean Architecture**, modular design, and scalable systems.

---

## 🚀 Why `jozz_events`?

### ✅ Clean Architecture Friendly

- Events are fully decoupled from emitters and listeners.
- Works across layers: UI, Application, Domain, Infrastructure.
- Perfect for feature-based modular projects.

### ✅ Typed, Predictable, and Testable

- No string-based events or untyped channels.
- Built with Dart's type system using generics and sealed base classes.

### ✅ Framework-Agnostic

- No dependency on Flutter or any UI toolkit.
- Can be used in Dart CLIs, server apps, or Flutter mobile/web/desktop.

### ✅ Lifecycle Aware

- Optional lifecycle management for Bloc, Cubit, State, or any component.
- Auto-dispose subscriptions on destruction.

### ✅ Simpler and Safer Than Alternatives

| Package            | Clean Arch Friendly | Strongly Typed | Lifecycle Support | Global Singleton | DI-Friendly |
| ------------------ | ------------------- | -------------- | ----------------- | ---------------- | ----------- |
| `jozz_events`      | ✅ Yes              | ✅ Yes         | ✅ Yes            | ❌ Opt-in only   | ✅ Yes      |
| `event_bus`        | ❌ No               | ❌ No          | ❌ No             | ✅ Always        | ❌ No       |
| Bloc-to-Bloc Comm. | ❌ Tight Coupling   | ✅ Yes         | ✅ Yes            | ❌               | ✅ Yes      |
| Signals            | ❌ UI-focused       | ✅ Yes         | ✅ (via hooks)    | ❌               | ⚠️ UI-tied  |

---

## 🧱 Use Case Example

**You have two features:**

- A `TodoService` that emits `TodoCreatedEvent`
- A `NotificationModule` that listens for this event and displays a notification

🧠 These two features must be completely unaware of each other — and `jozz_events` makes that easy.

---

## 📦 Installation

```yaml
dependencies:
  jozz_events: ^latest
```

Then import it:

```dart
import 'package:jozz_events/jozz_events.dart';
```

---

## 🛠️ Getting Started

### 1. Define a Domain Event

```dart
class TodoCreatedEvent extends JozzEvent {
  final String todoId;
  final String title;

  const TodoCreatedEvent({required this.todoId, required this.title});
}
```

---

### 2. Create a Shared Event Bus (or inject it)

```dart
final JozzBus eventBus = JozzBusService();
```

---

### 3. Emit the Event (e.g., inside a service)

```dart
eventBus.emit(TodoCreatedEvent(todoId: '1', title: 'Buy milk'));
```

Or using fluent API:

```dart
eventBus
  .emitEvent(TodoCreatedEvent(todoId: '1', title: 'Buy milk'))
  .emitEvent(TodoCreatedEvent(todoId: '2', title: 'Call mom'));
```

---

### 4. Listen for the Event (e.g., in a notification module)

```dart
eventBus.on<TodoCreatedEvent>().listen((event) {
  print('NOTIFICATION: New todo created: ${event.title}');
});
```

---

### 5. Manage Subscriptions

```dart
final sub = eventBus.listen<TodoCreatedEvent>((event) {
  print('Handling todo: ${event.todoId}');
});

// later
sub.cancel();
```

---

### 6. Use Lifecycle Mixins (Optional, Recommended for BLoC/Cubit)

```dart
class MyBloc with JozzLifecycleMixin {
  final JozzBus _eventBus;

  MyBloc(this._eventBus) {
    _eventBus.autoListen<TodoCreatedEvent>(this, _onTodoCreated);
  }

  void _onTodoCreated(TodoCreatedEvent event) {
    // handle logic
  }

  @override
  Future<void> close() {
    disposeJozzSubscriptions();
    return super.close();
  }
}
```

---

## 🧪 Testing

Mock `JozzBus` and verify behavior easily:

```dart
final mockBus = MockJozzBus();
when(() => mockBus.on<TodoCreatedEvent>()).thenAnswer((_) => Stream.value(TodoCreatedEvent(...)));
```

---

## ✅ Features

- ✅ Strongly typed events
- ✅ No tight coupling between features
- ✅ Clean architecture ready
- ✅ Pure Dart — no Flutter dependency
- ✅ Lifecycle support for widgets, blocs, cubits, etc.
- ✅ Fluent event emission
- ✅ Easy testing & mocking

---

## 📁 Clean Architecture Example Structure

```
features/
├── todo/
│   ├── domain/events/todo_created_event.dart
│   └── application/todo_service.dart
└── notifications/
    └── presentation/notification_listener.dart
```

Both features are fully decoupled. Communication happens through `JozzBus`.
Created by developers who love Clean Architecture and hate spaghetti.

---

## 📢 Coming Soon

- ✅ Singleton opt-in with `JozzBus.instance`
- ✅ Flutter integration subpackage
- 🧪 Built-in testing utilities
- 🧩 Middleware or interceptors (event logging)
- 📡 Namespaced topics or channels

---

## 🔗 License

MIT © Jozz

---
