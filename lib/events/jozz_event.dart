/// Abstract base class for all domain events.
///
/// This acts as a marker interface for domain events in the application.
/// Extend this class to create custom domain events that can be published
/// through the JozzBusService.
abstract class JozzEvent {
  const JozzEvent();
}
