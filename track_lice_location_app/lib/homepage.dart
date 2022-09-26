import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double latitude = 0;
  double longitude = 0;

  MapType _currentMapType = MapType.hybrid;

  permissions() async {
    await Permission.location.request();
  }

  liveCoordinates() async {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    });
  }

  Completer<GoogleMapController> mapController = Completer();
  late CameraPosition position;

  @override
  void initState() {
    super.initState();
    permissions();
    liveCoordinates();
    position = CameraPosition(
      target: LatLng(latitude, longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Locator App"),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () {
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () async {
                liveCoordinates();
                setState(() {
                  position = CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 12,
                  );
                });
                final GoogleMapController controller =
                    await mapController.future;
                controller
                    .animateCamera(CameraUpdate.newCameraPosition(position));
              },
              icon: const Icon(Icons.gps_fixed, color: Colors.white),
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Co-ordinates:",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "$latitude, $longitude",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 12,
                child: GoogleMap(
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      mapController.complete(controller);
                    },
                    //mapType: _currentMapType,
                    initialCameraPosition: position,
                    markers: <Marker>{
                      Marker(
                        markerId: const MarkerId("Current Location"),
                        position: LatLng(latitude, longitude),
                      ),
                    }),
              ),
            ],
          ),
        ));
  }
}
