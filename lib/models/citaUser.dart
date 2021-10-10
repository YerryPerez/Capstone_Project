import 'package:cloud_firestore/cloud_firestore.dart';

class CitaUser {

  String uid;
  String name;
  String gender;
  String photo;
  Timestamp age;
  GeoPoint location;

  CitaUser(
      {this.uid,
        this.name,
        this.gender,
        this.photo,
        this.age,
        this.location});
}
