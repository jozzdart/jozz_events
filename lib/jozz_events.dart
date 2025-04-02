/// The jozz_events library provides a domain-driven, event-based communication system.
///
/// This package provides a lightweight, framework-agnostic event bus implementation
/// that follows domain-driven design principles. It allows different components
/// of an application to communicate without direct dependencies on each other.
library jozz_events;

// Core components
export 'bus/jozz_bus.dart';
export 'bus/jozz_bus_service.dart';
export 'bus/jozz_bus_subscription.dart';

// Events
export 'events/jozz_event.dart';

// Extensions
export 'extensions/jozz_bus_extensions.dart';

// Lifecycle support
export 'lifecycle/jozz_lifecycle_mixin.dart';
export 'lifecycle/jozz_lifecycle_handler.dart';
