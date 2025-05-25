## 1.1.4

- Lowered Dart SDK constraint to `>=2.12.0 <4.0.0` for wider compatibility
- Moved internal files to `lib/src/` to improve encapsulation and API clarity
- Updated README links and improved navigation
- Renamed the global singleton `JozzEvents` to `Jozz` for easier usage, old name still works but is deprecated
  - Example:
    ```dart
    JozzEvents.bus.emit(event); // Old
    Jozz.bus.emit(event); // New
    ```

## 1.1.3

- Fixed more issues in CHANGELOG when displayed on pub.dev

## 1.1.2

- Updated README and added new logo and badges
- Fixed issues in CHANGELOG

## 1.1.1

- Updated README

## 1.1.0

### Added

- Optional singleton pattern (`JozzEvents`) for non-Clean Architecture projects that still provides advantages over alternative solutions
- Comprehensive test suite for the new singleton implementation ensuring reliability
- Complete Clean Architecture integration tutorial in the README with practical examples

### Improved

- README structure and content with clearer, more concise explanations
- Documentation for singleton usage with best practice recommendations
- Overall package organization and developer experience

## 1.0.1

- `JozzBus` interface and `JozzBusService` implementation
- Strongly-typed domain event system
- Fluent API (`emitEvent`)
- Lifecycle support with `JozzLifecycleMixin`
- Subscription helpers (`JozzBusSubscription`)
- Auto disposal of event listeners
