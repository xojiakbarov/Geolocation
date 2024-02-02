import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Geolocation',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String location = 'Distance Between: ';
  Position? myPosition;

  TextEditingController _latController = TextEditingController();
  TextEditingController _longController = TextEditingController();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<void> _getDistanceLocation() async {
    double lat = double.parse(_latController.text);
    double long = double.parse(_longController.text);
    final distance = await Geolocator.distanceBetween(
      myPosition!.latitude,
      myPosition!.longitude,
      lat,
      long,
    );

    setState(() {
      location = 'Distance Between: $distance';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${myPosition?.latitude}, ${myPosition?.longitude}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 36),
            ElevatedButton(
                onPressed: () async {
                  myPosition = await _determinePosition();
                  setState(() {});
                },
                child: Icon(Icons.location_on)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _latController,
                    decoration: InputDecoration(
                      labelText: 'Lat',
                      hintText: 'Latitude',
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _longController,
                    decoration: InputDecoration(
                      labelText: 'Long',
                      hintText: 'Longitude',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              location,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _getDistanceLocation();
          print(_latController.runtimeType);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
