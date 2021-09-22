import 'package:flutter_test2/models/citaUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({FirebaseFirestore firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<CitaUser> chooseUser(currentUserId, selectedUserId, name, photoUrl) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Likes')
        .doc(selectedUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('Likes')
        .doc(currentUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('LikedYou')
        .doc(currentUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });
    return getUser(currentUserId);
  }

  passUser(currentUserId, selectedUserId) async {
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('Likes')
        .doc(currentUserId)
        .set({});

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Likes')
        .doc(selectedUserId)
        .set({});

    return getUser(currentUserId);
  }

  // change this to location
  Future getUserInterests(userId) async {
    CitaUser currentUser = CitaUser();

    await _firestore.collection('users').doc(userId).get().then((user) {
      currentUser.name = user['name'];
      currentUser.photo = user['photoUrl'];
      currentUser.gender = user['gender'];
      currentUser.interestedIn = user['interestedIn'];
    });
    return currentUser;
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

  Future<List> getUserLocations(userId) async{
    List<String> preferences = [];
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('Location Preferences')
        .get().then(
            (docs){
          for(var doc in docs.docs){
            if (docs.docs != null){
              preferences.add(doc.id);
            }
          }
        }
    );
    return preferences;
  }

  Future<CitaUser> getUser(userId) async{
   CitaUser _user = CitaUser();
   List<String> chosenList = await getChosenList(userId);
   // User currentUser = await getUserInterests(userId);
   List<String> preferencesOfCurrentUser = await getUserLocations(userId);

   // Set<String> potentialMatches = await getPotentialMatches(userId);

   await _firestore.collection('users')
   .get().then((users) async {
     for(var user in users.docs){
       List<String> preferencesOfOtherUser = await getUserLocations(user.id);
       if (preferencesOfCurrentUser.any((element) => preferencesOfOtherUser.contains(element))
       && !chosenList.contains(user.id) && user.id!=userId){
         _user.uid = user.id;
         _user.name = user['name'];
         _user.photo = user['photoUrl'];
         _user.age = user['age'];
         _user.location = user['location'];
         _user.gender = user['gender'];
         _user.interestedIn = user['interestedIn'];
         break;
       }
     }
   });
   return _user;
  }
}
