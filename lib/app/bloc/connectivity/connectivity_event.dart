abstract class ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final bool isOnline;

  ConnectivityChanged(this.isOnline);
}
