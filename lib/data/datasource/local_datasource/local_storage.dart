import 'package:hive/hive.dart';

import 'package:location/location.dart';

import '../../models/location_point.dart';

class LocationStorage {
  final Box<LocationPoint> _box;

  LocationStorage(this._box);

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

    await _box.put("current_point",point);
  }



  LocationPoint? getCurrentPoint() {
    return _box.get("current_point");
  }


  Future<void> clearAll() async {
    await _box.clear();
  }
}
