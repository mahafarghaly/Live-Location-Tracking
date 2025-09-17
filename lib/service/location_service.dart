import 'dart:async';
import 'package:live_location_tracking/service/sensor_speed_service.dart';
import 'package:location/location.dart';

import '../data/local_storage.dart';

class LocationService {
  final LocationStorage _storage;

  LocationService(this._storage);

  final Location _location = Location();
  final SensorSpeedService _sensorSpeedService = SensorSpeedService();
  double storedLat = 38.3945703;
  double storedLong = -121.5828798;
  DateTime storedTimestamp = DateTime.now().subtract(
    const Duration(minutes: 20),
  );

  Future<void> init() async {
    await checkAndRequestLocationService();
    bool hasPermission = await checkAndRequestLocationPermission();
    if (hasPermission) {
      await configureLocationUpdates();
      await getLocationData();
    }
  }

  Future<void> checkAndRequestLocationService() async {
    bool isServiceEnabled = await _location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await _location.requestService();
      if (!isServiceEnabled) {
        ///TODO: show error bar
      }
    }
  }

  Future<bool> checkAndRequestLocationPermission() async {
    var permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> configureLocationUpdates() async {
    await _location.changeSettings(
      interval: 10000, //60000=1 minute
      distanceFilter: 0,
    );
  }

  Future<void> getLocationData() async {
    _location.onLocationChanged.listen((locationData) async {
      print(
        "late: ${locationData.latitude}, long: ${locationData.longitude},speed: ${locationData.speed}, time: ${locationData.time} ",
      );
      _sensorSpeedService.start();
      await Future.delayed(const Duration(seconds: 1));
      _sensorSpeedService.stop();
      print(
        "Sensor-based speed: ${_sensorSpeedService.currentSpeed.toStringAsFixed(2)} m/s "
        "(${(_sensorSpeedService.currentSpeed * 3.6).toStringAsFixed(2)} km/h)",
      );
      final speedKM = (_sensorSpeedService.currentSpeed * 3.6).toStringAsFixed(
        2,
      );
      await _storage.saveLocationPoint(
        locationData: locationData,
        speedKM: speedKM,
      );
      final point = _storage.getCurrentPoint();
      if (point != null) {
        print(
          '📍 Current point: '
          'Lat: ${point.latitude}, '
          'Lng: ${point.longitude}, '
          'Time: ${point.timestamp}, '
          'Speed: ${point.speed}',
        );
      } else {
        print('No point saved yet.');
      }
    });
  }
}
