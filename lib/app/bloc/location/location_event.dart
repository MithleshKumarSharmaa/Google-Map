abstract class LocationEvent {}

class StartLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final double latitude;
  final double longitude;

  LocationUpdated(this.latitude, this.longitude);
}
