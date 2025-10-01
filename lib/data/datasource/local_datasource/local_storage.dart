import 'package:hive/hive.dart';
import 'package:live_location_tracking/core/utils/constants/live_location_constants.dart';
import 'package:location/location.dart';
import '../../models/location_point.dart';
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


  Future<void> saveTrip(List<Map<String, dynamic>> points) async {
    await _tripBox.put(LiveLocationConstants.lastTripKey, points);
  }
  List<Map<String, dynamic>> getLastTrip() {
    final data = _tripBox.get(
      LiveLocationConstants.lastTripKey,
      defaultValue: <Map<String, dynamic>>[],
    ) as List<dynamic>;
    return data.map((e) => {
      "lat": (e["lat"] as num).toDouble(),
      "lng": (e["lng"] as num).toDouble(),
    }).toList();
  }
  LocationPoint? getCurrentPoint() {
    return _box.get(LiveLocationConstants.currentPointKey);
  }


  Future<void> clearAll() async {
    await _box.clear();
  }
}
