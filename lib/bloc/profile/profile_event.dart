part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class NameChanged extends ProfileEvent{
  final String name;

  NameChanged({@required this.name});

  @override
  List<Object> get props => [];
}

class PhotoChanged extends ProfileEvent{
  final File photo;

  PhotoChanged({@required this.photo});

  @override
  List<Object> get props => [];
}

class AgeChanged extends ProfileEvent{
  final DateTime age;

  AgeChanged({@required this.age});

  @override
  List<Object> get props => [];
}

class GenderChanged extends ProfileEvent{
  final String gender;

  GenderChanged({@required this.gender});

  @override
  List<Object> get props => [];
}

class InterestedInChanged extends ProfileEvent{
  final String interestedIn;

  InterestedInChanged({@required this.interestedIn});

  @override
  List<Object> get props => [];
}

class LocationChanged extends ProfileEvent{
  final GeoPoint location;

  LocationChanged({@required this.location});

  @override
  List<Object> get props => [];
}

class DeleteProfile extends ProfileEvent{
  final DeleteProfile userId;

  DeleteProfile({@required this.userId});
  @override
  List<Object> get props => [];
}



class Submitted extends ProfileEvent{
  final String name, gender, interestedIn;
  final DateTime age;
  final GeoPoint location;
  final File photo;

  Submitted({@required this.name,
    @required this.gender,
    @required this.interestedIn,
    @required this.age,
    @required this.location,
    @required this.photo});

  @override
  List<Object> get props => [location, name, age, gender, interestedIn, photo];
}

class SubmittedWithoutImage extends ProfileEvent{
  final String name, gender, interestedIn, url;
  final DateTime age;
  final GeoPoint location;

  SubmittedWithoutImage({@required this.name,
    @required this.gender,
    @required this.interestedIn,
    @required this.age,
    @required this.location,
    @required this.url});

  @override
  List<Object> get props => [location, name, age, gender, interestedIn, url];
}
