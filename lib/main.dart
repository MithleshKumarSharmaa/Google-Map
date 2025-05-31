import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:google_map/app/bloc/location/location_bloc.dart';
import 'package:google_map/app/ui/live_tracking_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityBloc()),
        BlocProvider(create: (_) => LocationBloc()),
      ],
      child:  MaterialApp(
          theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: LiveTrackingMap(),
      ),
    );
  }
}





