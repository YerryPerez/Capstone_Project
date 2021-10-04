import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test2/repositories/userRepository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  UserRepository _userRepository;

  ProfileBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(ProfileState.empty());

  ProfileState get initialState => ProfileState.empty();

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is NameChanged){
      yield* _mapNameChangedToState(event.name);
    }
    else if (event is AgeChanged){
      yield* _mapAgeChangedToState(event.age);
    }
    else if(event is GenderChanged){
    yield* _mapGenderChangedToState(event.gender);
    }
    else if(event is LocationChanged){
      yield* _mapLocationChangedToState(event.location);
    }
    else if(event is PhotoChanged){
      yield* _mapPhotoChangedToState(event.photo);
    }
    else if(event is DeleteProfile){
      //yield* _mapPhotoChangedToState(event.photo);
    }
    else if(event is Submitted){
      final uid = await _userRepository.getUser();
      yield* _mapSubmittedToState(
        photo: event.photo,
        name: event.name,
        gender: event.gender,
        userId: uid,
        age: event.age,
        location: event.location
      );
    }
    else if(event is SubmittedWithoutImage){
      final uid = await _userRepository.getUser();
      yield* _mapSubmittedWithoutImageToState(
        //  photo: event.photo,
          name: event.name,
          gender: event.gender,
          userId: uid,
          age: event.age,
          location: event.location,
          url: event.url
      );
    }
  }

  Stream <ProfileState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameEmpty: name == null,
    );
  }
  Stream <ProfileState> _mapPhotoChangedToState(File photo) async* {
    yield state.update(
      isPhotoEmpty: photo == null,
    );
  }
  Stream <ProfileState> _mapAgeChangedToState(DateTime age) async* {
    yield state.update(
      isAgeEmpty: age == null,
    );
  }
  Stream <ProfileState> _mapGenderChangedToState(String gender) async* {
    yield state.update(
      isGenderEmpty: gender == null,
    );
  }
  Stream <ProfileState> _mapLocationChangedToState(GeoPoint location) async* {
    yield state.update(
      isLocationEmpty: location == null,
    );
  }

  Stream<ProfileState> _mapSubmittedToState({File photo, String name, String gender, String userId,
    DateTime age, GeoPoint location}) async* {
      yield ProfileState.loading();
      try{
        await _userRepository.profileSetUp(photo, userId, name,
            gender, age, location);
        yield ProfileState.success();
      }
      catch (_){
        yield ProfileState.failure();
      }
  }

  Stream<ProfileState> _mapSubmittedWithoutImageToState({String name, String gender, String userId,
    DateTime age, GeoPoint location, String url}) async* {
    yield ProfileState.loading();
    try{
      await _userRepository.profileSetUpWithoutImage(userId, name,
          gender, age, location, url);
      yield ProfileState.success();
    }
    catch (_){
      yield ProfileState.failure();
    }
  }
}
