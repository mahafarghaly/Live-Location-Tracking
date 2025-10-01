import 'package:flutter/material.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
class MapDisplay extends StatelessWidget {
  final List<TripPoint> tripPoints;
  const MapDisplay({super.key,required this.tripPoints});

  @override
  Widget build(BuildContext context) {
    return  TripMapScreen(tripPoints: tripPoints,

    );
  }
}