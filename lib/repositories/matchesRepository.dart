
import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test2/models/user.dart';

class MatchesRepository {
  final FirebaseFirestore _firestore;

  MatchesRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMatchedList(userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('matchedList')
        .snapshots();
  }

  Stream<QuerySnapshot> getSelectedList(userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('LikedYou')
        .snapshots();
  }

  Future<User> getUserDetails(userId) async
  {
    User _user = User();

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

  Future openChat({currentUserId, selectedUserId}) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(selectedUserId).set({
      'timestamp': DateTime.now()
    });

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chats')
        .doc(currentUserId).set({
      'timestamp': DateTime.now()
    });

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('matchedList')
        .doc(selectedUserId)
        .delete();

    await _firestore.collection('users').doc(selectedUserId).collection(
        'matchedList')
        .doc(currentUserId)
        .delete();
  }

  Future<void> deleteUserFromLikedYou(currentUserId, selectedUserId) async
  {
    return await _firestore.collection('users').doc(currentUserId).collection(
        'LikedYou')
        .doc(selectedUserId).delete();
  }

  Future<void> deleteUserMatchedList(currentUserId,selectedUserId) async
  {
    return await _firestore.collection('users').doc(currentUserId).collection(
        'matchedList')
        .doc(selectedUserId).delete();
  }

  Future<void> deleteUserFromOthersLikes(currentUserId,selectedUserId) async
  {
    return await _firestore.collection('users').doc(currentUserId).collection(
        'Likes')
        .doc(selectedUserId).delete();
  }

  Future<void> deleteUserFromAllLists(currentUserId) async
  {
    List<String> chosenList = await getChosenList(currentUserId);
    for(var user in chosenList)
      {
        deleteUserMatchedList(currentUserId, user);
        deleteUserFromLikedYou(currentUserId, user);
        deleteUserFromOthersLikes(currentUserId, user);
      }
  }

  Future selectUser(currentUserId, selectedUserId, currentUserName,
      currentUserPhotoUrl, selectedUserName, selectedUserPhotoUrl) async {
    deleteUserFromLikedYou(currentUserId, selectedUserId);

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('matchedList')
        .doc(selectedUserId)
        .set({
      'name': selectedUserName,
      'photoUrl': selectedUserPhotoUrl,
    });

    return await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('matchedList')
        .doc(currentUserId)
        .set({
      'name': currentUserName,
      'photoUrl': currentUserPhotoUrl,
    });
  }

  Future<List> getChosenList(userId) async{
    List<String> chosenList = [];
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('Likes')
        .get().then(
            (docs){
          for(var doc in docs.docs){
            if (docs.docs != null){
              chosenList.add(doc.id);
            }
          }
        }
    );
    return chosenList;
  }

}
