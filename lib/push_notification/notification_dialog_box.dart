import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tawsila_driver/global/global.dart';
import 'package:tawsila_driver/pages/new_trip_screen.dart';

import '../models/user_ride_request_information.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestInformation;

  const NotificationDialogBox({Key? key, this.userRideRequestInformation})
      : super(key: key);

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/car_logo.png',
                width: 160,
              ),
              const SizedBox(height: 15),
              const Text(
                'New Ride Request',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Divider(
                height: 2,
                thickness: 2,
                color: Colors.black45,
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  // origin location with icon
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
                          widget.userRideRequestInformation!.originAddress!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  // destination location with icon
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
                          widget
                              .userRideRequestInformation!.destinationAddress!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                height: 2,
                thickness: 2,
                color: Colors.black45,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      // cancel the ride request

                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel'.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();
                      // accept the ride request

                      acceptRideRequest(context);
                    },
                    child: Text(
                      'Accept'.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = '';
    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentFirebaseUser!.uid)
        .child('newRideStatus')
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(msg: 'This ride request do not exists');
      }
      if (getRideRequestId ==
          widget.userRideRequestInformation!.rideRequestId) {
        FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(currentFirebaseUser!.uid)
            .child('newRideStatus')
            .set('accepted');
        // trip started now - send driver to new trip screen
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => NewTripScreen(
                    userRideRequestDetails:
                        widget.userRideRequestInformation)));
      } else {
        Fluttertoast.showToast(msg: 'This ride request do not exist');
      }
    });
  }
}
