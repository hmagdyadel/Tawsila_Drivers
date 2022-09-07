import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tawsila_driver/models/user_ride_request_information.dart';

import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_google_map.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  const NewTripScreen({Key? key, this.userRideRequestDetails})
      : super(key: key);

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newTripGoogleMapController;
  String? buttonTitle = 'Arrived';
  Color buttonColor = Colors.green;
  Set<Marker> setOfMarkers = <Marker>{};
  Set<Circle> setOfCircle = <Circle>{};
  Set<Polyline> setOfPolyline = <Polyline>{};
  List<LatLng> polylinePositionsCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPadding = 0;
  static const CameraPosition _kLake = CameraPosition(
    target: LatLng(29.9406967, 31.2806411),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //google map

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kLake,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;
              setState(() {
                mapPadding = 350;
              });
              // black theme google  map
              blackThemeGoogleMap(newTripGoogleMapController);
              var driverCurrentLatLng = LatLng(
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude,
              );
              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;
              drawPolylineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng!);
            },
          ),
          // ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: 0.5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // duration
                    const Text(
                      '18 mins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    //username - icon
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestDetails!.username!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 18),
                    // user pickup address with icon
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/origin.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    // user drop of address with icon
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/destination.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(primary: buttonColor),
                        icon: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BuildContext returnContext() {
    return context;
  }

// step 1: when driver accepts the user ride request
// originLatLng = driver current location
  // destinationLatLng = user pick up location

  // step 2: driver already picked up the user in his car
  // originLatLng = user pick up location => driver current location
  // destinationLatLng = user drop off location
  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => const ProgressDialog(
              message: 'Please wait...',
            ));

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(returnContext());
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsList =
        pPoints.decodePolyline(directionDetailsInfo!.ePoints!);
    polylinePositionsCoordinates.clear();
    if (decodedPolylinePointsList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsList) {
        polylinePositionsCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    setOfPolyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.teal,
        polylineId: const PolylineId('PolylineId'),
        jointType: JointType.round,
        points: polylinePositionsCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      setOfPolyline.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }
    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: const MarkerId('originId'),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationId'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId('originId'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationId'),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );
    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }
}
