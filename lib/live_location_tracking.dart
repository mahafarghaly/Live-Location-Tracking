import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'core/service/motion_tracker.dart';
import 'core/service/sensor_speed_service.dart';
import 'data/datasource/local_datasource/local_storage.dart';
import 'core/utils/user_state.dart';
class LiveLocationTracking with WidgetsBindingObserver{
  final LocationStorage _storage;
  final Location _location = Location();
  late final SensorSpeedService _sensorSpeedService;
  late final MotionTracking _motionTracking;
  LiveLocationTracking(this._storage) {
    _sensorSpeedService = SensorSpeedService();
    _motionTracking = MotionTracking(_storage);
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("👀 App state changed: $state");
    if (state == AppLifecycleState.resumed) {
        try {
          if(await _location.isBackgroundModeEnabled() == false){
          final backgroundModeEnabled =
          await _location.enableBackgroundMode(enable: true);
          print("🔄 Background mode enabled: $backgroundModeEnabled");
          if (backgroundModeEnabled) {
            await init();
          }
          }
          print("🔄 Background mode already enabled*************");
        } catch (e) {
          print("⚠️ Failed to re-enable background mode: $e");
        }
    }
  }
  Future<void> init() async {
    await checkAndRequestLocationService();
    bool hasPermission = await checkAndRequestLocationPermission();
    try {
      if (hasPermission) {
        await configureLocationUpdates();
      await _startLocationTracking();
      } else {
        _motionTracking.setState(UserState.lostConnection);
      }
    } catch (e) {
      _motionTracking.setState(UserState.lostConnection);
      print("❌ Location init error: $e");
    }
  }

  Future<void> checkAndRequestLocationService() async {
    bool isServiceEnabled = await _location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await _location.requestService();
      if (!isServiceEnabled) {
        _motionTracking.setState(UserState.lostConnection);
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
      interval: 10000, ///TODO 60000=1 minute
      distanceFilter: 0,

    );
  }

  Future<void> _startLocationTracking() async {
    _location.onLocationChanged.listen((locationData) async {
      try {

        if (locationData.latitude == null || locationData.longitude == null) {
          _motionTracking.setState(UserState.lostConnection);
          return;
        }
        await _sensorSpeedService.start();

        final speedKM = _sensorSpeedService.currentSpeed * 3.6;
        final storedLocation = _storage.getCurrentPoint();
      await _storage.saveLocationPoint(
          locationData: locationData,
          speedKM: speedKM.toStringAsFixed(2),
        );
        print("📍current Location: ${locationData.latitude}, ${locationData.longitude}, Speed: ${speedKM.toStringAsFixed(2)} km/h");
       print("###storedLocation Location: ${storedLocation?.latitude}, ${storedLocation?.longitude}, Speed: ${storedLocation?.speed.toStringAsFixed(2)} km/h");
        if (storedLocation != null) {
          final userState = _motionTracking.handleStateLogic(
            lastLocation: storedLocation,
            locationData: locationData,
            //speedKM: speedKM,
          );
          print("😡 userState $userState");
        } else {
          print("⚠️ No stored location yet");
        }
      } catch (e) {
        _motionTracking.setState(UserState.lostConnection);
        print("⚠️ Location error: $e");
      }
    });
  }
  List<List<Map<String,dynamic>>> get allTrips => _motionTracking.allTrips;
  void dispose() {
    _motionTracking.cancelTimers();
    _sensorSpeedService.stop();
    WidgetsBinding.instance.removeObserver(this);
  }

}
