import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
String locationName;
String locationAddress;
LatLng latLong;
String fullName;

  Location(
      {this.locationName,
        this.locationAddress,
      this.latLong,
      this.fullName});
}
