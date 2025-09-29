import 'dart:async';
import 'dart:math';
import 'package:live_location_tracking/service/sensor_speed_service.dart';
import 'package:live_location_tracking/core/user_state.dart';
import 'package:location/location.dart';

import '../data/models/location_point.dart';


// class MotionTracking {
//   Timer? _idleTimer;
//   Timer? _endTimer;
//   UserState _currentState = UserState.idle;
//
//   final SensorSpeedService _sensorSpeedService;
//   MotionTracking(this._sensorSpeedService);
//
//   UserState handleStateLogic({
//     required LocationPoint lastLocation,
//     required LocationData locationData,
//     required double speedKM,
//   }) {
//     const double speedThreshold = 1.0;///TODO 25 km/h
//
//     if (locationData.latitude == null || locationData.longitude == null) {
//       return setState(UserState.lostConnection);
//     }
//     if (speedKM >= speedThreshold) {
//       cancelTimers();
//       if (_currentState == UserState.idle || _currentState == UserState.end) {
//         return setState(UserState.start);
//       } else if (_currentState == UserState.start || _currentState == UserState.resume) {
//         return setState(UserState.resume);
//       }
//     } else {//<25
//       if (_currentState == UserState.start || _currentState == UserState.resume) {
//         return startIdleTimer(lastLocation: lastLocation, locationData: locationData);
//       }
//     }
//
//     return _currentState;
//   }
//
//   UserState startIdleTimer({
//     required LocationPoint lastLocation,
//     required LocationData locationData,
//   }) {
//     cancelTimers();
//     print("⏳ Starting 5-min idle timer...");
//     setState(UserState.idle);
//
//     _idleTimer = Timer(const Duration(minutes: 5), () {
//       if (isStillIdle(lastLocation: lastLocation, locationData: locationData)) {
//         print("⏳ Starting 10-min end timer...");
//         _endTimer = Timer(const Duration(minutes: 10), () {
//           if (isStillIdle(lastLocation: lastLocation, locationData: locationData)) {
//             setState(UserState.end);
//           }
//         });
//       }
//     });
//
//     return _currentState;
//   }
//
//   bool isStillIdle({
//     required LocationPoint lastLocation,
//     required LocationData locationData,
//   }) {
//     final stillSlow = _sensorSpeedService.currentSpeed * 3.6 < 1.0;///TODO 25 km/h
//     final sameLocation = calculateDistance(
//       lastLocation.latitude,
//       lastLocation.longitude,
//       locationData.latitude!,
//       locationData.longitude!,
//     ) < 5.0;
//     print("👻 same Location... $sameLocation");
//     return sameLocation && stillSlow;
//   }
//
//   void cancelTimers() {
//     _idleTimer?.cancel();
//     _endTimer?.cancel();
//   }
//
//   UserState setState(UserState newState) {
//     if (_currentState != newState) {
//       _currentState = newState;
//       print("🔄 User state changed: $_currentState");
//     }
//     return _currentState;
//   }
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const earthRadius = 6371000;
//     final dLat = _degToRad(lat2 - lat1);
//     final dLon = _degToRad(lon2 - lon1);
//     final a =
//         (sin(dLat / 2) * sin(dLat / 2)) +
//             cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
//                 (sin(dLon / 2) * sin(dLon / 2));
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return earthRadius * c;
//   }
//
//   double _degToRad(double deg) => deg * (pi / 180);
// }
class MotionTracking {
  Timer? _idleTimer;
  Timer? _endTimer;
  UserState _currentState = UserState.idle;

  MotionTracking();

  UserState handleStateLogic({
    required LocationPoint lastLocation,
    required LocationData locationData,
  }) {
    const double movementThreshold = 10.0; // -->meters///TODO 25KM/H

    if (locationData.latitude == null || locationData.longitude == null) {
      return setState(UserState.lostConnection);
    }

    final distanceMoved = calculateDistance(
      lastLocation.latitude,
      lastLocation.longitude,
      locationData.latitude!,
      locationData.longitude!,
    );
   print("----------------distanceMoved: $distanceMoved");
    if (distanceMoved >= movementThreshold) {
      cancelTimers();
      if (_currentState == UserState.idle || _currentState == UserState.end) {
        return setState(UserState.start);
      }
      // else if (_currentState == UserState.start || _currentState == UserState.resume) {
      //   return setState(UserState.resume);
      // }
    } else {
      if (_currentState == UserState.start ) {
        return startIdleTimer(lastLocation: lastLocation, locationData: locationData);
      }
    }

    return _currentState;
  }

  UserState startIdleTimer({
    required LocationPoint lastLocation,
    required LocationData locationData,
  }) {
    cancelTimers();
    print("⏳ Starting 5-min idle timer...");
    setState(UserState.idle);

    _idleTimer = Timer(const Duration(minutes: 5), () {
      if (isStillIdle(lastLocation: lastLocation, locationData: locationData)) {
        print("⏳ Starting 10-min end timer...");
        _endTimer = Timer(const Duration(minutes: 10), () {
          if (isStillIdle(lastLocation: lastLocation, locationData: locationData)) {
            setState(UserState.end);
          }
        });
      }
    });

    return _currentState;
  }

  bool isStillIdle({
    required LocationPoint lastLocation,
    required LocationData locationData,
  }) {
    final sameLocation = calculateDistance(
      lastLocation.latitude,
      lastLocation.longitude,
      locationData.latitude!,
      locationData.longitude!,
    ) < 5.0;
    print("👻 same Location... $sameLocation");
    return sameLocation;
  }

  void cancelTimers() {
    _idleTimer?.cancel();
    _endTimer?.cancel();
  }

  UserState setState(UserState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      print("🔄 User state changed: $_currentState");
    }
    return _currentState;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
