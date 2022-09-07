import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tawsila_driver/global/global.dart';
import 'package:tawsila_driver/models/user_ride_request_information.dart';
import 'package:tawsila_driver/push_notification/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    // 1- Terminated state ( when the app is completely closed and opened directly from the push notification)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // display ride request information - user information who request a ride
        readUserRideRequestInformation(
            remoteMessage.data['rideRequestId'], context);
      }
    });

    // 2- Foreground state ( when the app is open and it receives a push notification)
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // display ride request information - user information who request a ride
      readUserRideRequestInformation(
          remoteMessage!.data['rideRequestId'], context);
    });
    // 3- Background state ( when the app is in the background and opened directly from the push notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // display ride request information - user information who request a ride
      readUserRideRequestInformation(
          remoteMessage!.data['rideRequestId'], context);
    });
  }

  Future generateAndGetToken() async {
    // generate and get token from .getToken()
    String? registrationToken = await messaging.getToken();

    // save the token to database to specific driver
    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentFirebaseUser!.uid)
        .child('token')
        .set(registrationToken);

    messaging.subscribeToTopic('allDrivers');
    messaging.subscribeToTopic('allUsers');
  }

  readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(userRideRequestId)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        audioPlayer.open(Audio('assets/sounds/music_notification.mp3'));
        audioPlayer.play();

        double originLat = double.parse(
            (snapData.snapshot.value! as Map)['origin']['latitude']);
        double originLng = double.parse(
            (snapData.snapshot.value! as Map)['origin']['longitude']);
        String originAddress =
            (snapData.snapshot.value! as Map)['originAddress'];
        double destinationLat = double.parse(
            (snapData.snapshot.value! as Map)['destination']['latitude']);
        double destinationLng = double.parse(
            (snapData.snapshot.value! as Map)['destination']['longitude']);
        String destinationAddress =
            (snapData.snapshot.value! as Map)['destinationAddress'];

        String username = (snapData.snapshot.value! as Map)['username'];
        String userPhone = (snapData.snapshot.value! as Map)['userPhone'];
        UserRideRequestInformation userRideRequestDetails =
            UserRideRequestInformation();
        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequestDetails.originAddress = originAddress;
        userRideRequestDetails.destinationAddress = destinationAddress;
        userRideRequestDetails.username = username;
        userRideRequestDetails.userPhone = userPhone;
        userRideRequestDetails.rideRequestId =snapData.snapshot.key;
        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
              userRideRequestInformation: userRideRequestDetails),
        );
      } else {
        Fluttertoast.showToast(msg: 'This ride request do not exist.');
      }
    });
  }
}
