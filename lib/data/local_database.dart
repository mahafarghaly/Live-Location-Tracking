import 'package:live_location_tracking/models/location_model.dart';
import 'package:live_location_tracking/models/synced_records_data.dart';

abstract class LocalDatabase{
  Future<dynamic> initDB();
  Future<int> insertLocation(LocationModel location);
  Future<int> updateLocation(LocationModel location);
  Future<int> deleteLocation(int id);
  Future<LocationModel?> getLocationById(int id);
  Future<List<LocationModel>> getFirst50Unsynced();
  Future<SyncedRecordsData> getSyncedRecordsData();
}