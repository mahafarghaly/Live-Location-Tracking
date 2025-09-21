import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_location_tracking/motion_tracker.dart';
import 'package:live_location_tracking/service/sensor_speed_service.dart';
import 'package:location/location.dart';

import '../data/local_storage.dart';
import '../user_state.dart';

class LocationService with WidgetsBindingObserver{
  final LocationStorage _storage;
  final Location _location = Location();
  late final SensorSpeedService _sensorSpeedService;
  late final MotionTracking _motionTracking;
  LocationService(this._storage) {
    _sensorSpeedService = SensorSpeedService();
    _motionTracking = MotionTracking(_sensorSpeedService);
    WidgetsBinding.instance.addObserver(this);
  }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async{
  //   print("👀 app state $state");
  //   final isBackground= await _location.isBackgroundModeEnabled();
  //
  //   if (state == AppLifecycleState.resumed&& isBackground==false) {
  //    await init();
  //   }
  // }
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
    try {
      final backgroundModeEnabled =
      await _location.enableBackgroundMode(enable: true);
      if (!backgroundModeEnabled) {
        print("⚠️ Background mode not enabled");
      }
    } catch (e) {
      print(
          "⚠️ Failed to enable background mode: $e");
    }
    return true;
  }

  Future<void> configureLocationUpdates() async {
    await _location.changeSettings(
      interval: 100, ///TODO 60000=1 minute
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
        final storedLocation =await _storage.getCurrentPoint();
      await _storage.saveLocationPoint(
          locationData: locationData,
          speedKM: speedKM.toStringAsFixed(2),
        );
        print("📍current Location: ${locationData.latitude}, ${locationData.longitude}, Speed: ${speedKM.toStringAsFixed(2)} km/h");
      //  print("###storedLocation Location: ${storedLocation?.latitude}, ${storedLocation?.longitude}, Speed: ${storedLocation?.speed.toStringAsFixed(2)} km/h");
        if (storedLocation != null) {
          final userState = _motionTracking.handleStateLogic(
            lastLocation: storedLocation,
            locationData: locationData,
            speedKM: speedKM,
          );
          print("😡 userState $userState");
        } else {
          print("⚠️ No stored location yet");
        }
      } catch (e,stack) {
        _motionTracking.setState(UserState.lostConnection);
        print("⚠️ Location error: $e");
        print(stack);
      }
    });
  }
  void dispose() {
    _motionTracking.cancelTimers();
    _sensorSpeedService.stop();
    WidgetsBinding.instance.removeObserver(this);
  }

}
