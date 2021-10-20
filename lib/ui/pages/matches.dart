import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/matches/matches_bloc.dart';
import 'package:flutter_test2/models/citaUser.dart';
import 'package:flutter_test2/models/location.dart';
import 'package:flutter_test2/repositories/matchesRepository.dart';
import 'package:flutter_test2/repositories/searchRepository.dart';
import 'package:flutter_test2/ui/widgets/iconWidget.dart';
import 'package:flutter_test2/ui/widgets/map.dart';
import 'package:flutter_test2/ui/widgets/pageTurn.dart';
import 'package:flutter_test2/ui/widgets/profile.dart';
import 'package:flutter_test2/ui/widgets/userGender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants.dart';
import 'messaging.dart';


class Matches extends StatefulWidget {
  final String userId;

  const Matches({this.userId});

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  MatchesRepository matchesRepository = MatchesRepository();
  final SearchRepository _searchRepository = SearchRepository();


  MatchesBloc _matchesBloc;
  int difference;

  getDifference(GeoPoint userLocation) async {
    Position position = await Geolocator.getCurrentPosition();
    double location = Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, position.latitude, position.longitude);

    difference = location.toInt();
  }

  Future<List<Location>> getCommonLocations(SearchRepository _search, CitaUser selectedUser) async {
    List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
    List<String> list2 = await _searchRepository.getUserLocations(selectedUser.uid.toString());
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
    return commonLocations;
  }


  @override
  void initState() {
    _matchesBloc = MatchesBloc(matchesRepository: matchesRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<MatchesBloc, MatchesState>(
      bloc: _matchesBloc,
      builder: (BuildContext context, MatchesState state) {
        if (state is LoadingState) {
          _matchesBloc.add(LoadListsEvent(userId: widget.userId));
          return CircularProgressIndicator();
        }
        if (state is LoadUserState) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                title: Text(
                  "Matched User",
                  style: TextStyle(color: Colors.black, fontSize: 30.0),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: state.matchedList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  }
                  if (snapshot.data.docs != null) {
                    final user = snapshot.data.docs;
                    var matchCount = snapshot.data.size;
                    if(matchCount>4)
                      matchCount=4;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              CitaUser selectedUser = await matchesRepository
                                  .getUserDetails(user[index].id);
                              CitaUser currentUser = await matchesRepository
                                  .getUserDetails(widget.userId);
                              await getDifference(selectedUser.location);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: profileWidget(
                                    photo: selectedUser.photo,
                                    photoHeight: size.height,
                                    padding: size.height * 0.01,
                                    photoWidth: size.width,
                                    clipRadius: size.height * 0.01,
                                    containerWidth: size.width,
                                    containerHeight: size.height * 0.2,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.height * 0.02),
                                      child: ListView(
                                        children: <Widget>[
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              userGender(selectedUser.gender),
                                              Expanded(
                                                child: Text(
                                                  " " +
                                                      selectedUser.name +
                                                      ", " +
                                                      (DateTime.now().year -
                                                          selectedUser.age
                                                              .toDate()
                                                              .year)
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                      size.height * 0.05),
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
                                                    ? (difference / 1000)
                                                    .floor()
                                                    .toString() +
                                                    " km away"
                                                    : "away",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    size.height * 0.02),
                                                child: iconWidget(Icons.message,
                                                        () {
                                                      _matchesBloc.add(
                                                        OpenChatEvent(
                                                            currentUser:
                                                            widget.userId,
                                                            selectedUser:
                                                            selectedUser.uid),
                                                      );
                                                      pageTurn(
                                                          Messaging(
                                                              currentUser:
                                                              currentUser,
                                                              selectedUser:
                                                              selectedUser),
                                                          context);
                                                    }, size.height * 0.04,
                                                    Colors.white),

                                              ),
                                              Padding(
                                                  padding: EdgeInsets.all(
                                                      size.height * 0.02),

                                              child: iconWidget(FontAwesomeIcons.mapMarked,
                                                      () async {
                                                    List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
                                                    List<String> list2 = await _searchRepository.getUserLocations(selectedUser.uid.toString());
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
                                                                    future: getCommonLocations(_searchRepository,selectedUser),
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
                                                  }, size.height * .04, Colors.white))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: profileWidget(
                              padding: size.height * 0.01,
                              photo: user[index].get('photoUrl'),
                              photoWidth: size.width * 0.5,
                              photoHeight: size.height * 0.3,
                              clipRadius: size.height * 0.01,
                              containerHeight: size.height * 0.03,
                              containerWidth: size.width * 0.5,
                              child: Text(
                                "  " + user[index].get('name'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        childCount: user.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  }
                },
              ),
              SliverAppBar(
                backgroundColor: Colors.white,
                pinned: true,
                title: Text(
                  "Someone Likes You",
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: state.selectedList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  }
                  if (snapshot.data.docs != null) {
                    final user = snapshot.data.docs;
                    var matchCount = snapshot.data.size;
                    if(matchCount>4)
                      matchCount=4;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              CitaUser selectedUser = await matchesRepository
                                  .getUserDetails(user[index].id);
                              CitaUser currentUser = await matchesRepository
                                  .getUserDetails(widget.userId);

                              await getDifference(selectedUser.location);
                              // ignore: missing_return
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: profileWidget(
                                    padding: size.height * 0.01,
                                    photo: selectedUser.photo,
                                    photoHeight: size.height,
                                    photoWidth: size.width,
                                    clipRadius: size.height * 0.01,
                                    containerWidth: size.width,
                                    containerHeight: size.height * 0.2,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.height * 0.02),
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    userGender(
                                                        selectedUser.gender),
                                                    Expanded(
                                                      child: Text(
                                                        " " +
                                                            selectedUser.name +
                                                            ", " +
                                                            (DateTime.now()
                                                                .year -
                                                                selectedUser
                                                                    .age
                                                                    .toDate()
                                                                    .year)
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                            size.height *
                                                                0.05),
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
                                                          ? (difference / 1000)
                                                          .floor()
                                                          .toString() +
                                                          " km away"
                                                          : "away",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    iconWidget(Icons.clear, () {
                                                      _matchesBloc.add(
                                                        DeleteUserEvent(
                                                            currentUser:
                                                            currentUser.uid,
                                                            selectedUser:
                                                            selectedUser
                                                                .uid),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    }, size.height * 0.08,
                                                        Colors.blue),
                                                    SizedBox(
                                                      width: size.width * 0.05,
                                                    ),
                                                    iconWidget(
                                                        FontAwesomeIcons
                                                            .solidHeart, () {
                                                      _matchesBloc.add(
                                                        AcceptUserEvent(
                                                            selectedUser:
                                                            selectedUser
                                                                .uid,
                                                            currentUser:
                                                            currentUser.uid,
                                                            currentUserPhotoUrl:
                                                            currentUser
                                                                .photo,
                                                            currentUserName:
                                                            currentUser
                                                                .name,
                                                            selectedUserPhotoUrl:
                                                            selectedUser
                                                                .photo,
                                                            selectedUserName:
                                                            selectedUser
                                                                .name),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    }, size.height * 0.06,
                                                        Colors.red),
                                                    SizedBox(
                                                      width: size.width * 0.08,
                                                    ),
                                                    iconWidget(FontAwesomeIcons.mapMarked,
                                                            () async {
                                                          List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
                                                          List<String> list2 = await _searchRepository.getUserLocations(selectedUser.uid.toString());
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
                                                                          future: getCommonLocations(_searchRepository,selectedUser),
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
                                                        }, size.height * .04, Colors.white)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: profileWidget(
                              padding: size.height * 0.01,
                              photo: user[index].get('photoUrl'),
                              photoWidth: size.width * 0.5,
                              photoHeight: size.height * 0.3,
                              clipRadius: size.height * 0.01,
                              containerHeight: size.height * 0.03,
                              containerWidth: size.width * 0.5,
                              child: Text(
                                "  " + user[index].get('name'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        childCount: user.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4),
                    );
                  } else
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                },
              ),
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                title: Text(
                  "Pending Likes",
                  style: TextStyle(color: Colors.black, fontSize: 30.0),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: state.pendingList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  }
                  if (snapshot.data.docs != null) {
                    final user = snapshot.data.docs;
                    var matchCount = snapshot.data.size;
                    if(matchCount>4)
                      matchCount=4;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              CitaUser selectedUser = await matchesRepository
                                  .getUserDetails(user[index].id);
                              CitaUser currentUser = await matchesRepository
                                  .getUserDetails(widget.userId);
                              await getDifference(selectedUser.location);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: profileWidget(
                                    photo: selectedUser.photo,
                                    photoHeight: size.height,
                                    padding: size.height * 0.01,
                                    photoWidth: size.width,
                                    clipRadius: size.height * 0.01,
                                    containerWidth: size.width,
                                    containerHeight: size.height * 0.2,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.height * 0.02),
                                      child: ListView(
                                        children: <Widget>[
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              userGender(selectedUser.gender),
                                              Expanded(
                                                child: Text(
                                                  " " +
                                                      selectedUser.name +
                                                      ", " +
                                                      (DateTime.now().year -
                                                          selectedUser.age
                                                              .toDate()
                                                              .year)
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                      size.height * 0.05),
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
                                                    ? (difference / 1000)
                                                    .floor()
                                                    .toString() +
                                                    " km away"
                                                    : "away",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    size.height * 0.02),
                                                child:  iconWidget(Icons.clear, () {
                                                  _matchesBloc.add(
                                                    DeleteUserEvent(
                                                        currentUser:
                                                        currentUser.uid,
                                                        selectedUser:
                                                        selectedUser
                                                            .uid),
                                                  );
                                                  Navigator.of(context)
                                                      .pop();
                                                    }, size.height * 0.04,
                                                    Colors.white),

                                              ),
                                              Padding(
                                                  padding: EdgeInsets.all(
                                                      size.height * 0.02),

                                                  child: iconWidget(FontAwesomeIcons.mapMarked,
                                                          () async {
                                                        List<String> list1 = await _searchRepository.getUserLocations(widget.userId.toString());
                                                        List<String> list2 = await _searchRepository.getUserLocations(selectedUser.uid.toString());
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
                                                                        future: getCommonLocations(_searchRepository,selectedUser),
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
                                                      }, size.height * .04, Colors.white))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: profileWidget(
                              padding: size.height * 0.01,
                              photo: user[index].get('photoUrl'),
                              photoWidth: size.width * 0.5,
                              photoHeight: size.height * 0.3,
                              clipRadius: size.height * 0.01,
                              containerHeight: size.height * 0.03,
                              containerWidth: size.width * 0.5,
                              child: Text(
                                "  " + user[index].get('name'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        childCount: user.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  }
                },
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}