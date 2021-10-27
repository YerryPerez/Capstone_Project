
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'matchesRepository.dart';


class UserRepository{
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final MatchesRepository _matchesRepository = MatchesRepository();
  UserRepository({
    FirebaseAuth firebaseAuth,
    FirebaseFirestore firestore}): _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance, _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> signInWithEmail( String email, String password){
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<bool> isFirstTime(String userId) async{
    bool exist;
    await FirebaseFirestore.instance.collection('users').doc(userId).get().then((user){
      exist = user.exists;
    });

    return exist;
  }

  Future<void> signUpWithEmail(String email, String password) async{
    print(_firebaseAuth);
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async{
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (_firebaseAuth.currentUser).uid;
  }

  //profile setup

  Future<void> profileSetUp(
      File photo,
      String userId,
      String name,
      String gender,
      DateTime age,
      GeoPoint location
      ) async{
      UploadTask uploadTask = FirebaseStorage.instance.ref().
      child('userPhotos').child(userId).child(userId).putFile(photo);



      return await uploadTask.whenComplete(() => null).then(
          (ref) async {
            await ref.ref.getDownloadURL().then((url) async{


              var chosenList = await _matchesRepository.getChosenList(userId);

              for(var chosenUser in chosenList) {
                var likedYouList = await _matchesRepository.getLikedYouList(chosenUser);
                for (var user in likedYouList) {
                  if (user == userId) {
                    print("---------------------");
                    var a = await _firestore
                        .collection('users')
                        .doc(chosenUser)
                        .collection('LikedYou')
                        .doc(userId).update(<String, dynamic>{
                      'name': name,
                      'photoUrl': url

                    });
                  }
                }
              }
              var matchList = await _matchesRepository.getMatchedUsersList(userId);

              for(var chosenUser in matchList){
                var otherUsersMatched = await _matchesRepository.getMatchedUsersList(chosenUser);
                for(var user in otherUsersMatched){
                  if(user== userId){
                    print("---------------------");
                    var a = await _firestore
                        .collection('users')
                        .doc(chosenUser)
                        .collection('matchedList')
                        .doc(userId).update(<String, dynamic>{
                      'name': name,
                      'photoUrl': url

                    });
                  }
                }


              }


              await _firestore.collection('users').doc(userId).set({
                'uid': userId,
                'photoUrl': url,
                'name': name,
                'location': location,
                'gender': gender,
                'age': age
              });





            });
          });


  }

  Future<void> profileSetUpWithoutImage(
      String userId,
      String name,
      String gender,
      DateTime age,
      GeoPoint location,
      String url,
      ) async{

    var chosenList = await _matchesRepository.getChosenList(userId);

    for(var chosenUser in chosenList) {
      var likedYouList = await _matchesRepository.getLikedYouList(chosenUser);
      for (var user in likedYouList) {
        if (user == userId) {
          print("---------------------");
          var a = await _firestore
              .collection('users')
              .doc(chosenUser)
              .collection('LikedYou')
              .doc(userId).update(<String, dynamic>{
            'name': name
          });
        }
      }
    }
      var matchList = await _matchesRepository.getMatchedUsersList(userId);

      for(var chosenUser in matchList){
        var otherUsersMatched = await _matchesRepository.getMatchedUsersList(chosenUser);
        for(var user in otherUsersMatched){
          if(user== userId){
            print("---------------------");
            var a = await _firestore
                .collection('users')
                .doc(chosenUser)
                .collection('matchedList')
                .doc(userId).update(<String, dynamic>{
              'name': name
            });
          }
        }


    }


    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'photoUrl': url,
      'name': name,
      'location': location,
      'gender': gender,
      'age': age

    });
  }

  //TODO: Delete user account
  Future<void> deleteProfile(
      String userId
      ) async{
    return  await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> addLocationPreference(String collectionID,String streetNumber, String streetName, String city, String zipcode, String locationName, LatLng locationCords) async
  {
    return await _firestore.collection("locations").doc(collectionID).set(
      {
        'streetNumber':streetNumber,
        'streetName' : streetName,
        'city' : city,
        'zipcode': zipcode,
        'locationName' : locationName,
        'lat' : locationCords.latitude,
        'lng' : locationCords.longitude
      });
  }

  Future<void> addUserToLocationCollection(String collectionID, String UserId) async
  {
    return await _firestore.collection('locations').doc(collectionID).collection(UserId).doc(UserId.toString()).set({});
  }

  Future<void> addLocationToUserCollection(String collectionID, String UserId) async
  {
    return await _firestore.collection('users').doc(UserId).collection('Location Preferences').doc(collectionID).set({});
  }

  Future<void> removeLocationFromUserCollection(String collectionID,String UserId) async
  {
    return await _firestore.collection('users').doc(UserId).collection('Location Preferences').doc(collectionID).delete();
  }
}