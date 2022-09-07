import 'package:flutter/material.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickupLocation,userDropOffLocation;

  void updatePickupLocationAddress(Directions userPickupAddress) {
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
