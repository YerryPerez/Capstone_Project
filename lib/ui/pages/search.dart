import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/search/search_bloc.dart';
import 'package:flutter_test2/models/citaUser.dart';
import 'package:flutter_test2/models/location.dart';
import 'package:flutter_test2/repositories/searchRepository.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/widgets/iconWidget.dart';
import 'package:flutter_test2/ui/widgets/map.dart';
import 'package:flutter_test2/ui/widgets/profile.dart';
import 'package:flutter_test2/ui/widgets/userGender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Search extends StatefulWidget {
  final String userId;

  const Search({this.userId});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final SearchRepository _searchRepository = SearchRepository();
  SearchBloc _searchBloc;
  CitaUser _user, _currentUser;
  int difference;

  getDifference(GeoPoint userLocation) async {
    Position position = await Geolocator.getCurrentPosition();
    double location = Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, position.latitude, position.longitude);

    difference = location.toInt();
  }

  Future<List<Location>> getCommonLocations(SearchRepository _search) async {
    List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
    List<String> list2 = await _searchRepository.getUserLocations(_user.uid.toString());
    List<Location> commonLocations = [];
      for (String s in list1) {
        if (list2.contains(s)) {
        // String name = s.substring(s.lastIndexOf(",") + 1,s.length);
          List<String> locationDetails = s.split(",");
          String address = s.substring(0, s.lastIndexOf(","));
         Location localWithName = Location();
        localWithName.locationName =
        locationDetails[4];
        localWithName.locationAddress = locationDetails[0] + locationDetails[1] + "\n" + locationDetails[2] + " " + locationDetails[3] + "\n";
          localWithName.latLong = new LatLng(double.parse(locationDetails[5]), double.parse(locationDetails[6]));
        commonLocations.add(localWithName);
      }
    }

    // for (var s in data) {
    //   List<String> locationDetails = s.split(",");
    //   Location localWithName = Location();
    //   localWithName.locationName = locationDetails[4];
    //   if (localWithName.locationName.length > 40) {
    //     String s = localWithName.locationName;
    //     s = s.substring(0, 40);
    //     s = s.substring(0, s.lastIndexOf(" "));
    //     localWithName.locationName = s + "...";
    //   }
    //   localWithName.locationAddress = locationDetails[0] +
    //       locationDetails[1] +
    //       "\n" +
    //       locationDetails[2] +
    //       " " +
    //       locationDetails[3] +
    //       "\n";
    //   localWithName.latLong = new LatLng(
    //       double.parse(locationDetails[5]), double.parse(locationDetails[6]));
    //   locations.add(localWithName);
    // }
    return commonLocations;
  }



  @override
  void initState() {
    _searchBloc = SearchBloc(searchRepository: _searchRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state is InitialSearchState) {
          _searchBloc.add(
            LoadUserEvent(userId: widget.userId),
          );
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
          ));
        }
        if (state is LoadingState) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
            ),
          );
        }
        if (state is LoadUserState) {
          _user = state.user;
          _currentUser = state.currentUser;

          getDifference(_user.location);
          if (_user.location == null) {
            return Text(
              "No more profiles to show",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            );
          } else
            return SingleChildScrollView(
                child: profileWidget(
                    padding: size.height * .035,
                    photoHeight: size.height * .824,
                    photoWidth: size.width * .95,
                    photo: _user.photo,
                    clipRadius: size.height * .02,
                    containerHeight: size.height * .3,
                    containerWidth: size.width * .9,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * .02),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: size.height * .07,
                              ),
                              Row(
                                children: <Widget>[
                                  userGender(_user.gender),
                                  Expanded(
                                    child: Text(
                                      " " +
                                          _user.name +
                                          ", " +
                                          (DateTime.now().year -
                                                  _user.age.toDate().year)
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.height * 0.05),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  Text(
                                      difference != null
                                          ? ((difference / 1000) * .62137119224)
                                                  .floor()
                                                  .toString() +
                                              "miles away"
                                          : "away",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              SizedBox(
                                  height: size.height * .05,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      iconWidget(Icons.clear, () {
                                        _searchBloc.add(PassUserEvent(
                                            widget.userId, _user.uid));
                                      }, size.height * .08, Colors.blue),
                                      iconWidget(FontAwesomeIcons.solidHeart,
                                          () {
                                        _searchBloc.add(
                                          SelectUserEvent(
                                              name: _currentUser.name,
                                              photoUrl: _currentUser.photo,
                                              currentUserId: widget.userId,
                                              selectedUserId: _user.uid),
                                        );
                                      }, size.height * 0.06, Colors.red),
                                      iconWidget(FontAwesomeIcons.mapMarked,
                                          () async {
                                        List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
                                        List<String> list2 = await _searchRepository.getUserLocations(_user.uid.toString());
                                        List<Location> commonLocations = [];
                                        for (String s in list1) {
                                          if (list2.contains(s)) {
                                            // String name = s.substring(s.lastIndexOf(",") + 1,s.length);
                                            List<String> locationDetails = s.split(",");
                                            String address = s.substring(0, s.lastIndexOf(","));
                                            Location localWithName = Location();
                                            localWithName.locationName = locationDetails[4];
                                            localWithName.locationAddress = locationDetails[0] + locationDetails[1] + "\n" + locationDetails[2] + " " + locationDetails[3] + "\n";
                                            commonLocations.add(localWithName);
                                          }
                                        }
                                        print(commonLocations);
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Scaffold(
                                                  appBar: AppBar(
                                                    backgroundColor:
                                                        backgroundColor,
                                                    title: Text(
                                                        "Common Location Interests"),
                                                  ),
                                                  // height: MediaQuery.of(context).size.height * 0.5,
                                                  // width: MediaQuery.of(context).size.width,
                                                  body: Container(
                                                      child: FutureBuilder(
                                                    future: getCommonLocations(_searchRepository),
                                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                      if (snapshot.data == null) {
                                                        return Container(
                                                            child: Center(
                                                                child: Text("Loading Common Interests")));
                                                      } else {
                                                        return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (context, index) {
                                                              return new GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                      ..hideCurrentSnackBar()
                                                                      ..showSnackBar(
                                                                          SnackBar(
                                                                            duration: Duration(seconds: 2),
                                                                              content: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                              "Loading Map..."),
                                                                          CircularProgressIndicator(),
                                                                        ],
                                                                      )));
                                                                    Position
                                                                        pos =
                                                                        await Geolocator.getCurrentPosition(
                                                                            desiredAccuracy:
                                                                                LocationAccuracy.high);
                                                                    LatLng
                                                                        curr =
                                                                        new LatLng(
                                                                            pos.latitude,
                                                                            pos.longitude);
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                MapScreen(destinationPosition: snapshot.data[index].latLong, currentPosition: curr)));
                                                                  },
                                                                  child: Container(
                                                                      child: Card(
                                                                          elevation: 2.0,
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                          margin: const EdgeInsets.all(1.0),
                                                                          child: Padding(
                                                                            padding:
                                                                                EdgeInsets.all(16.0),
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Row(children: <Widget>[
                                                                                  Text(snapshot.data[index].locationName,
                                                                                      style: new TextStyle(
                                                                                        fontSize: 22.0,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      )),
                                                                                ]),
                                                                                Row(children: <Widget>[
                                                                                  Text((snapshot.data[index].locationAddress)),
                                                                                ]),
                                                                                Row(children: <Widget>[
                                                                                  Text("Tap to view",style: new TextStyle(fontSize: 12.0,color: Colors.blueGrey),)
                                                                                ])
                                                                              ],
                                                                            ),
                                                                          ))));
                                                              // title: Text(commonLocations[index].locationName),
                                                              //subtitle: Text((commonLocations[index].locationAddress),
                                                            });
                                                      }
                                                    },
                                                  )));
                                            });
                                      }, size.height * .04, Colors.white),
                                    ],
                                  ))
                            ]))));
        } else
          return Container();
      },
    );
  }
}
