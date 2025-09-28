class SyncedRecordModel {
  final int id;
  final double latitude;
  final double longitude;

  SyncedRecordModel({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory SyncedRecordModel.fromMap(Map<String, dynamic> map) {
    return SyncedRecordModel(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}