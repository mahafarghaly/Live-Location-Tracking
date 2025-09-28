class LocationModel {
  final int? id;
  final double latitude;
  final double longitude;
  final int timestamp; // unix epoch
  final double? accuracy;
  final double? speed;
  final int? battery;
  final String? network; // WiFi / Cellular
  final int synced; // 0 = pending, 1 = synced

  LocationModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.battery,
    this.network,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'accuracy': accuracy,
      'speed': speed,
      'battery': battery,
      'network': network,
      'synced': synced,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: map['timestamp'],
      accuracy: map['accuracy'],
      speed: map['speed'],
      battery: map['battery'],
      network: map['network'],
      synced: map['synced'],
    );
  }
}