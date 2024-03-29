import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test2/models/citaUser.dart';

class UserAccountRepository {
  final FirebaseFirestore _firestore;

  UserAccountRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


  Future<CitaUser> getUserDetails(String userId) async
  {
    CitaUser _user = CitaUser();

    await _firestore.collection('users').doc(userId).get().then((user) {
      _user.uid = user['uid'];
      _user.name = user['name'];
      _user.photo = user['photoUrl'];
      _user.age = user['age'];
      _user.location = user['location'];
      _user.gender = user['gender'];
      _user.interestedIn = user['interestedIn'];
    });

    return _user;
  }
}