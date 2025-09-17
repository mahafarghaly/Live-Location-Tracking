import 'package:flutter/material.dart';
import 'package:live_location_tracking/data/local_storage.dart';
import 'package:live_location_tracking/models/location_point.dart';
import 'package:live_location_tracking/service/location_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(LocationPointAdapter());
  final box = await Hive.openBox<LocationPoint>('location_points');
  final storage = LocationStorage(box);
  final locationService = LocationService(storage);
  runApp(MyApp(locationService: locationService,));
}

class MyApp extends StatefulWidget {
  final LocationService locationService;
  const MyApp({super.key, required this.locationService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.locationService.init();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on:\n'),
        ),
      ),
    );
  }
}
