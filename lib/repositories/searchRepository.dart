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

  Future getUserInterests(userId) async {
    CitaUser currentUser = CitaUser();

    await _firestore.collection('users').doc(userId).get().then((user) {
      currentUser.name = user['name'];
      currentUser.photo = user['photoUrl'];
      currentUser.gender = user['gender'];
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

  Future<CitaUser> getUser(userId) async{
   CitaUser _user = CitaUser();
   List<String> chosenList = await getChosenList(userId);
   CitaUser currentUser = await getUserInterests(userId);

   await _firestore.collection('users')
   .get().then((users){
     for(var user in users.docs){
       if (!chosenList.contains(user.id) && user.id != userId){
         _user.uid = user.id;
         _user.name = user['name'];
         _user.photo = user['photoUrl'];
         _user.age = user['age'];
         _user.location = user['location'];
         _user.gender = user['gender'];
         break;
       }
     }
   });
   return _user;
  }
}
