import 'package:hive/hive.dart';
part 'location_point.g.dart';

@HiveType(typeId: 0)
class LocationPoint {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final double timestamp;

  @HiveField(4)
  final double speed;

  LocationPoint({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
  });
}

