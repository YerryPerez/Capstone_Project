
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserRepository{
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

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
      String interestedIn,
      DateTime age,
      GeoPoint location
      ) async{
      UploadTask uploadTask = FirebaseStorage.instance.ref().
      child('userPhotos').child(userId).child(userId).putFile(photo);

      return await uploadTask.whenComplete(() => null).then(
          (ref) async {
            await ref.ref.getDownloadURL().then((url) async{
              await _firestore.collection('users').doc(userId).set({
                'uid': userId,
                'photoUrl': url,
                'name': name,
                'location': location,
                'gender': gender,
                'interestedIn': interestedIn,
                'age': age
              });
            });
          });
  }
  //Delete user account
  Future<void> deleteProfile(
      File photo,
      String userId,
      String name,
      String gender,
      String interestedIn,
      DateTime age,
      GeoPoint location
      ) async{

    return  await _firestore.collection('users').doc(userId).delete();


  }

}