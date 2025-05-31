import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map/app/bloc/location/location_bloc.dart';
import 'package:google_map/app/bloc/location/location_event.dart';
import 'package:google_map/app/bloc/location/location_state.dart';
import 'package:google_map/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:google_map/app/bloc/connectivity/connectivity_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingMap extends StatefulWidget {
  const LiveTrackingMap({super.key});

  @override
  State<LiveTrackingMap> createState() => LiveTrackingMapState();
}

class LiveTrackingMapState extends State<LiveTrackingMap> {
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(StartLocationTracking());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You're offline"), backgroundColor: Colors.red),
          );
        } else if (state is ConnectivityOnline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You're online"), backgroundColor: Colors.green),
          );
          // Optionally restart location tracking
          context.read<LocationBloc>().add(StartLocationTracking());
        }
      },
      child: Scaffold(
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoadInProgress || state is LocationInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LocationLoadSuccess) {
              mapController?.animateCamera(CameraUpdate.newLatLng(state.position));
              return GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: state.position,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("live_location"),
                    position: state.position,
                  )
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            } else if (state is LocationLoadFailure) {
              return Center(child: Text("Error: ${state.error}"));
            } else {
              return const Center(child: Text("Unknown state"));
            }
          },
        ),
      ),
    );
  }
}
