import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
class MapDisplay extends StatelessWidget {
  final List<LatLng> tripPoints;
  const MapDisplay({super.key,required this.tripPoints});

  @override
  Widget build(BuildContext context) {
    return  TripMapScreen(tripPoints: tripPoints,

    );
  }
}