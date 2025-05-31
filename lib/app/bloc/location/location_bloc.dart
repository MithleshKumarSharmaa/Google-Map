import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStream;

  LocationBloc() : super(LocationInitial()) {
    on<StartLocationTracking>((event, emit) async {
      emit(LocationLoadInProgress());

      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity == ConnectivityResult.none) {
          emit(LocationLoadFailure("No internet connection"));
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          emit(LocationLoadFailure("Location permission denied"));
          return;
        }

        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
          ),
        ).listen((position) {
          add(LocationUpdated(position.latitude, position.longitude));
        }, onError: (e) {
          emit(LocationLoadFailure("Location stream error: $e"));
        });
      } catch (e) {
        emit(LocationLoadFailure("Exception: ${e.toString()}"));
      }
    });

    on<LocationUpdated>((event, emit) {
      emit(LocationLoadSuccess(LatLng(event.latitude, event.longitude)));
    });
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}
