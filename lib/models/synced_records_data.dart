import 'package:live_location_tracking/models/synced_record_model.dart';

class SyncedRecordsData {
  final int count;
  final List<SyncedRecordModel> records;

  SyncedRecordsData({
    required this.count,
    required this.records,
  });
}