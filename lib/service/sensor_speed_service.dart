import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorSpeedService {
  double _currentSpeed = 0.0;
  DateTime? _lastUpdateTime;
  StreamSubscription? _accelSubscription;
  final StreamController<double> _speedController =
      StreamController.broadcast();

  Stream<double> get onSpeedChanged => _speedController.stream;

  double get currentSpeed => _currentSpeed;

  Future<void> start() async {
    _lastUpdateTime = DateTime.now();
    _accelSubscription = userAccelerometerEvents.listen((event) {
      final now = DateTime.now();
      final dt = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
      _lastUpdateTime = now;
      double accMagnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      //if (accMagnitude.abs() < 0.1) accMagnitude = 0.0;
      _currentSpeed += accMagnitude * dt;
      if (_currentSpeed < 0) _currentSpeed = 0.0;
      _speedController.add(_currentSpeed);
    //  print("currentspeed::$_currentSpeed , accMagnitude :$accMagnitude , time$dt");
    },
      onError: (error){
      /// TODO Toast message
        //Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
  }

  void stop() {
    _accelSubscription?.cancel();
    _speedController.close();
  }
}
