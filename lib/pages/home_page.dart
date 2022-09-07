import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tawsila_driver/global/global.dart';
import 'package:tawsila_driver/push_notification/push_notification_system.dart';
import 'package:tawsila_driver/splash/splash_screen.dart';

import '../assistants/black_theme_google_map.dart';
import '../assistants/request_assistant.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? googleMapController;
  static const CameraPosition _kLake = CameraPosition(
    target: LatLng(29.9406967, 31.2806411),
    zoom: 14,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String statusText = 'Now Offline';
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  BuildContext returnContext() {
    return context;
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverCurrentPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = currentPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    print(driverCurrentPosition!.latitude);
    print(driverCurrentPosition!.longitude);
    String humanReadableAddress =
        await RequestAssistant.searchAddressForGeographicCoordinates(
            driverCurrentPosition!, returnContext());
    print('this is your address: $humanReadableAddress');
  }

  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kLake,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            googleMapController = controller;
            blackThemeGoogleMap(googleMapController);
            // for black theme google  map
            locateDriverCurrentPosition();
          },
        ),
        statusText != 'Now Online'
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),
        Positioned(
          top: statusText != 'Now Online'
              ? MediaQuery.of(context).size.height * 0.46
              : 35,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isDriverActive != true) {
                    driverIsOnlineNow();
                    updateDriverLocationAtRealTime();
                    setState(() {
                      statusText = 'Now Online';
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });
                    Fluttertoast.showToast(msg: 'You are online now.');
                  } else {
                    driverIsOfflineNow();
                    setState(() {
                      statusText = 'Now Offline';
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: 'You are offline now.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != 'Now Online'
                    ? Text(
                        statusText,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  driverIsOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = position;
    Geofire.initialize('activeDrivers');
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentFirebaseUser!.uid)
        .child('newRideStatus');
    reference.set('idle'); //searching for ride request
    reference.onValue.listen((event) {});
  }

  updateDriverLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      if (isDriverActive == true) {
        Geofire.setLocation(
          currentFirebaseUser!.uid,
          driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude,
        );
      }
      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );
      googleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? reference = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentFirebaseUser!.uid)
        .child('newRideStatus');
    reference.onDisconnect();
    reference.remove();
    reference = null;
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => const SplashView()));
    });
  }
}
