# 📦 jozz_events

> **Domain-first, framework-agnostic event system for Clean Architecture**

**`jozz_events`** is a lightweight, strongly-typed, and modular event bus designed for **Clean Architecture**. It enables scalable, maintainable, and **decoupled communication** across your application’s features and layers.

Ideal for Dart projects (including Flutter), this package brings clarity and safety to event-driven design with first-class support for modularity, testability, and lifecycle awareness — **without any external dependencies**.

---

## 🚀 Why `jozz_events`?

| Feature              | `jozz_events` | `event_bus` | Bloc-to-Bloc | Signals      |
| -------------------- | ------------- | ----------- | ------------ | ------------ |
| Clean Arch Friendly  | ✅            | ❌          | ❌ (Tight)   | ❌ (UI-tied) |
| Strong Typing        | ✅            | ❌          | ✅           | ✅           |
| Lifecycle Support    | ✅            | ❌          | ✅           | ⚠️ via hooks |
| Global Singleton     | ✅ Optional   | ✅ Always   | ❌           | ❌           |
| Dependency Injection | ✅            | ❌          | ✅           | ⚠️           |

<details>
<summary>✅ Built for Clean Architecture</summary>

- Events are **decoupled** from emitters and listeners.
- Cross-layer support: **UI**, **Application**, **Domain**, and **Infrastructure**.
- Perfect for **feature-based** modular systems.
</details>

<details>
<summary>✅ Strongly Typed & Predictable</summary>

- No string-based identifiers or dynamic types.
- Built entirely with Dart's **type-safe** system.
- Clear, explicit contracts via `JozzEvent`.
</details>

<details>
<summary>✅ Framework-Agnostic</summary>

- No Flutter dependency.
- Works in **Dart CLIs**, **server apps**, and **Flutter** (mobile/web/desktop).
</details>

<details>
<summary>✅ Lifecycle-Aware</summary>

- Optional lifecycle mixins for **Bloc**, **Cubit**, **State**, etc.
- Subscriptions are cleaned up automatically when components are disposed.
</details>

---

- [Why jozz_events?](#-why-jozz_events)
- [Use Case Example](#-use-case-example)
- [Using the Global Singleton](#-using-the-global-singleton)
- [Why not just `event_bus`?](#-why-not-just-event_bus)
- [Features](#-features)
- [**Clean Architecture Integration Tutorial**](#-clean-architecture-integration-tutorial)

---

## 📦 Installation & Getting Started

```yaml
dependencies:
  jozz_events: ^latest
```

Then import it:

```dart
import 'package:jozz_events/jozz_events.dart';
```

---

## 🧱 Use Case Example

Two features need to communicate without knowing about each other:

- `TodoService` emits a `TodoCreatedEvent`
- `NotificationModule` listens and shows a message

### Define the Event

```dart
class TodoCreatedEvent extends JozzEvent {
  final String title;
  const TodoCreatedEvent(this.title);
}
```

### Emit the Event

```dart
eventBus.emit(TodoCreatedEvent('Buy milk'));
```

### Listen to the Event

```dart
eventBus.on<TodoCreatedEvent>().listen((event) {
  print('New todo: ${event.title}');
});
```

> That's it — no tight coupling, no service locators, just clean, type-safe communication.

👉 **For a full Clean Architecture integration**, see the [📦 Clean Architecture Integration Tutorial](#-clean-architecture-integration-tutorial).

👉 **For a quick singleton usage approach**, see the [🌍 Using the Global Singleton](#-using-the-global-singleton) section.

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

## 🌍 Using the Global Singleton

For small apps or rapid prototyping, use the global singleton:

```dart
import 'package:jozz_events/jozz_events.dart';

void main() {
  // Emit
  JozzEvents.bus.emit(TodoCreatedEvent(todoId: '123', title: 'Do dishes'));

  // Listen
  JozzEvents.bus.on<TodoCreatedEvent>().listen((event) {
    print('Global handler: ${event.title}');
  });
}
```

### Singleton Access

- `JozzEvents.bus`: Access as `JozzBus` interface (recommended for most usage).
- `JozzEvents.service`: Access full `JozzBusService` for advanced control (e.g. `dispose()`).

> ⚠️ **Note:** Use the singleton **only if you're not using dependency injection.** In large, scalable apps, prefer constructor injection and `JozzBusService` instances per module.

---

### 🧠 Why not just `event_bus`?

While `event_bus` is convenient, it comes with architectural compromises. Here's how `jozz_events` stands apart:

| Feature              | `jozz_events`   | `event_bus`       |
| -------------------- | --------------- | ----------------- |
| Strong Typing        | ✅ Yes          | ❌ No             |
| Lifecycle Support    | ✅ Auto-dispose | ❌ None           |
| Clean Arch Friendly  | ✅ Layered      | ❌ Tight Coupling |
| Dependency Injection | ✅ DI-first     | ❌ Singleton-only |
| Global Singleton     | ✅ Optional     | ✅ Always         |
| Testability          | ✅ Mockable     | ❌ Difficult      |

Even in non-Clean Architecture projects, **strong typing, lifecycle handling, and testability** make `jozz_events` a safer, more robust foundation for event-driven code.

---

## ✅ Features

- ✅ Strongly typed events
- ✅ No tight coupling between features
- ✅ Clean architecture ready
- ✅ Pure Dart — no Flutter dependency
- ✅ Lifecycle support for widgets, blocs, cubits, etc.
- ✅ Optional global singleton
- ✅ Fluent event emission
- ✅ Easy testing & mocking

## 📢 Coming Soon

- ✅ Flutter integration helpers
- 🧪 Testing utilities
- 🧩 Middleware & event interceptors (logging, side effects)
- 📡 Namespaced topics or channels for filtering

---

# 📦 Clean Architecture Integration Tutorial

> A step-by-step guide for integrating `jozz_events` into a modular, Clean Architecture Flutter project using `freezed`, `dartz`, and `injectable`

---

## 🧠 What Is `jozz_events` and Why Use It in Clean Architecture?

### 🧩 Problem:

In a large Clean Architecture app, features should not know about each other. But sometimes, one feature needs to trigger behavior in another. For example:

- The `subscription` feature completes a purchase.
- The `auth` feature needs to refresh custom claims.

### ⚠️ Naive Solutions:

- Inject `AuthBloc` into `subscription` (tight coupling ❌)
- Use global state or service locators manually (messy ❌)

### ✅ `jozz_events` Solves This By:

- Allowing **feature-level events** to be emitted and listened to with **no direct dependency**
- Supporting **strong typing**, **lifecycle-safe subscriptions**, and **Clean Architecture separation**

---

## 🛠️ 1. Install the Package

```yaml
dependencies:
  jozz_events: ^<latest>
```

## 🗂️ 2. Setup Event Bus for Dependency Injection

### In your `core` folder:

```dart
// core/events/jozz_bus_di.dart
import 'package:injectable/injectable.dart';
import 'package:jozz_events/jozz_events.dart';

@module
abstract class JozzBusModule {
  @lazySingleton
  JozzBus get eventBus => JozzBusService();
}
```

Inject it where needed:

```dart
final JozzBus jozzBus;

@injectable
MyBloc(this.jozzBus);
```

## 🧾 3. Create a Domain Event

```dart
// features/subscription/domain/events/subscription_purchased.dart
import 'package:jozz_events/jozz_events.dart';

class SubscriptionPurchased extends JozzEvent {
  const SubscriptionPurchased();
}
```

## 📤 4. Emit the Event from a Use Case

```dart
class PurchasePremium {
  final InAppPurchaseService _iap;
  final JozzBus _jozzBus;

  PurchasePremium(this._iap, this._jozzBus);

  Future<Either<Failure, Unit>> call() async {
    final result = await _iap.purchase();
    if (result.isRight()) {
      _jozzBus.emitEvent(const SubscriptionPurchased());
    }
    return result;
  }
}
```

## 📥 5. Listen to the Event in Another Feature

In your `AuthCubit`, use the `JozzLifecycleMixin` to auto-dispose:

```dart
class AuthCubit extends Cubit<AuthState> with JozzLifecycleMixin {
  final JozzBus _jozzBus;
  final RefreshUserClaims _refreshClaims;
  final GetSignedInUser _getUser;

  AuthCubit(this._jozzBus, this._refreshClaims, this._getUser) : super(...)
  {
    _jozzBus.autoListen<SubscriptionPurchased>(this, (_) async {
      await _refreshClaims();
      final user = await _getUser();
      emit(AuthState.authenticated(user.getOrElse(() => throw UnexpectedError())));
    });
  }

  @override
  Future<void> close() {
    disposeJozzSubscriptions();
    return super.close();
  }
}
```

## 🎯 Summary

- Use `jozz_events` to allow **features to communicate via domain events** without tight coupling
- Events are emitted from **use cases** and listened to in **Blocs, Cubits, or services**
- Integration is **clean, scalable, and testable**
- Especially useful for cross-feature flows like: `purchase → claims refresh`, `login → analytics`, `delete → undo`

---

## 🔗 License

MIT © Jozz
