# 📦 jozz_events

> **Domain-first, framework-agnostic event system for Clean Architecture**

**`jozz_events`** is a lightweight, strongly-typed, and modular event bus designed for **Clean Architecture**. It enables scalable, maintainable, and **decoupled communication** across your application’s features and layers.

Ideal for Dart projects (including Flutter), this package brings clarity and safety to event-driven design with first-class support for modularity, testability, and lifecycle awareness — **without any external dependencies**.

---

## 🚀 Why `jozz_events`?

### ✅ Built for Clean Architecture

- Events are **decoupled** from emitters and listeners.
- Cross-layer support: **UI**, **Application**, **Domain**, and **Infrastructure**.
- Perfect for **feature-based** modular systems.

### ✅ Strongly Typed & Predictable

- No string-based identifiers or dynamic types.
- Built entirely with Dart’s **type-safe** system.
- Clear, explicit contracts via `JozzEvent`.

### ✅ Framework-Agnostic

- No Flutter dependency.
- Works in **Dart CLIs**, **server apps**, and **Flutter** (mobile/web/desktop).

### ✅ Lifecycle-Aware

- Optional lifecycle mixins for **Bloc**, **Cubit**, **State**, etc.
- Subscriptions are cleaned up automatically when components are disposed.

### ✅ Simple, Testable, and Safer

| Feature              | `jozz_events` | `event_bus` | Bloc-to-Bloc | Signals      |
| -------------------- | ------------- | ----------- | ------------ | ------------ |
| Clean Arch Friendly  | ✅            | ❌          | ❌ (Tight)   | ❌ (UI-tied) |
| Strong Typing        | ✅            | ❌          | ✅           | ✅           |
| Lifecycle Support    | ✅            | ❌          | ✅           | ⚠️ via hooks |
| Global Singleton     | ❌ Opt-in     | ✅ Always   | ❌           | ❌           |
| Dependency Injection | ✅            | ❌          | ✅           | ⚠️           |

## 📑 Table of Contents

- [Why jozz_events?](#-why-jozz_events)
- [Use Case Example](#-use-case-example)

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
- ✅ Flutter integration helpers
- 🧪 Testing utilities
- 🧩 Middleware & event interceptors (logging, side effects)
- 📡 Namespaced topics or channels for filtering

---

## 🔗 License

MIT © Jozz

---
