import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


import '../global/map_key.dart';
import '../info_handler/app_info.dart';
import '../models/directions.dart';

class RequestAssistant {
  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    String humanReadableAddress = '';
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != 'Error occurred, no response.') {
      humanReadableAddress = requestResponse['results'][0]['formatted_address'];
      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }

  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      } else {
        return 'Error occurred, no response.';
      }
    } catch (exception) {
      return 'Error occurred, no response.';
    }
  }
}
