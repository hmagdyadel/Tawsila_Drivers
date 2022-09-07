import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../models/direction_details_info.dart';
import '../models/user_model.dart';
import 'request_assistant.dart';


class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(currentFirebaseUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print('name =${userModelCurrentInfo!.name}');
        print('email =${userModelCurrentInfo!.email}');
      }
    });
  }

  static Future<DirectionsDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey';
    var responseDirectionAPI = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);
    if (responseDirectionAPI == 'Error occurred, no response.') {
      return null;
    } else {
      DirectionsDetailsInfo directionsDetailsInfo = DirectionsDetailsInfo();
      directionsDetailsInfo.ePoints =
          responseDirectionAPI['routes'][0]['overview_polyline']['points'];

      directionsDetailsInfo.distanceText =
          responseDirectionAPI['routes'][0]['legs']['distance']['text'];
      directionsDetailsInfo.distanceValue =
          responseDirectionAPI['routes'][0]['legs']['distance']['value'];

      directionsDetailsInfo.durationText =
          responseDirectionAPI['routes'][0]['legs']['duration']['text'];
      directionsDetailsInfo.durationValue =
          responseDirectionAPI['routes'][0]['legs']['duration']['value'];
      return directionsDetailsInfo;
    }
  }
}
