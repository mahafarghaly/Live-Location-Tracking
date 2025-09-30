import 'package:flutter/material.dart';
import 'package:live_location_tracking/data/datasource/local_datasource/local_storage.dart';
import 'package:live_location_tracking/data/models/location_point.dart';
import 'package:live_location_tracking/live_location_tracking.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_location_tracking_example/map_display.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(LocationPointAdapter());
  final box = await Hive.openBox<LocationPoint>('location_points');
  final tripBox = await Hive.openBox('trip_points');
  final storage = LocationStorage(box,tripBox);
  final locationService = LiveLocationTracking(storage);
  runApp(MyApp(locationService: locationService,));
}

class MyApp extends StatefulWidget {
  final LiveLocationTracking locationService;
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
  void dispose() {
    super.dispose();
    widget.locationService.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final trips = widget.locationService.allTrips;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(onPressed: (){
              setState(() {

              });
            }, icon: Icon(Icons.refresh))
          ],
        ),
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: trips.isEmpty
          ? const Center(child: Text("No trips yet"))
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MapDisplay(tripPoints: trip)));
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip #${index + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("Points: ${trip.length}"),
                    Text("Start: ${trip.first.latitude}, ${trip.first.longitude}"),
                    Text("End: ${trip.last.latitude}, ${trip.last.longitude}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
      ),
    );
  }
}
