import 'package:hive/hive.dart';
import 'package:live_location_tracking/core/utils/constants/live_location_constants.dart';
import 'package:location/location.dart';

import '../../models/location_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class LocationStorage {
  final Box _box;
  final Box _tripBox;
  LocationStorage(this._box, this._tripBox);

  Future<void> saveLocationPoint({
    required LocationData locationData,
    required String speedKM,
  }) async {
    final point = LocationPoint(
      latitude: locationData.latitude ?? 0.0,
      longitude: locationData.longitude ?? 0.0,
      timestamp: locationData.time ??0.0,
      speed: double.tryParse(speedKM) ?? 0.0,
    );

    await _box.put(LiveLocationConstants.currentPointKey,point);
  }


  Future<void> saveTrip(List<LatLng> points) async {
    final data = points.map((p) => {"lat": p.latitude, "lng": p.longitude}).toList();
    await _tripBox.put(LiveLocationConstants.lastTripKey, data);
  }

  List<LatLng> getLastTrip() {
    final data = _tripBox.get(LiveLocationConstants.lastTripKey, defaultValue: []) as List<dynamic>;
    return data.map((e) => LatLng(e["lat"] as double, e["lng"] as double)).toList();
  }
  LocationPoint? getCurrentPoint() {
    return _box.get(LiveLocationConstants.currentPointKey);
  }


  Future<void> clearAll() async {
    await _box.clear();
  }
}
