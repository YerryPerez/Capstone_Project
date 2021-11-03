import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_test2/bloc/matches/matches_bloc.dart';
import 'package:flutter_test2/bloc/messaging/messaging_bloc.dart';
import 'package:flutter_test2/models/message.dart';
import 'package:flutter_test2/models/citaUser.dart';
import 'package:flutter_test2/repositories/matchesRepository.dart';
import 'package:flutter_test2/repositories/messaging.dart';
import 'package:flutter_test2/repositories/searchRepository.dart';
import 'package:flutter_test2/ui/widgets/iconWidget.dart';
import 'package:flutter_test2/ui/widgets/map.dart';
import 'package:flutter_test2/ui/widgets/message.dart';
import 'package:flutter_test2/ui/widgets/pageTurn.dart';
import 'package:flutter_test2/ui/widgets/photo.dart';
import 'package:flutter_test2/ui/widgets/profile.dart';
import 'package:flutter_test2/ui/widgets/userGender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_test2/models/location.dart';

import 'dart:io';
import '../constants.dart';class Messaging extends StatefulWidget {
  final CitaUser currentUser, selectedUser;

  const Messaging({this.currentUser, this.selectedUser});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  TextEditingController _messageTextController = TextEditingController();
  MessagingRepository _messagingRepository = MessagingRepository();
  MessagingBloc _messagingBloc;
  bool isValid = false;


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
    List<String> list1 = await _searchRepository.getUserLocations(widget.currentUser.uid.toString());
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
        if (localWithName.locationName.length > 30){
          String s = localWithName.locationName;
          s = s.substring(0, 30);
          s = s.substring(0,s.lastIndexOf(" "));
          localWithName.locationName = s + "...";
        }
        localWithName.locationAddress = locationDetails[0] + locationDetails[1] + "\n" + locationDetails[2] + " " + locationDetails[3] + "\n";
        localWithName.latLong = new LatLng(double.parse(locationDetails[5]), double.parse(locationDetails[6]));
        commonLocations.add(localWithName);
      }
    }
    return commonLocations;
  }


//  bool get isPopulated => _messageTextController.text.isNotEmpty;
//
//  bool isSubmitButtonEnabled(MessagingState state) {
//    return isPopulated;
//  }

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(messagingRepository: _messagingRepository);

    _messageTextController.text = '';
    _messageTextController.addListener(() {
      setState(() {
        isValid = (_messageTextController.text.isEmpty) ? false : true;
      });
    });
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    super.dispose();
  }

  void _onFormSubmitted() {
    print("Message Submitted");

    _messagingBloc.add(
      SendMessageEvent(
        message: Message(
          text: _messageTextController.text,
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.name,
          selectedUserId: widget.selectedUser.uid,
          photo: null,
        ),
      ),
    );
    _messageTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: size.height * 0.02,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            ClipOval(
              child:
                  GestureDetector(
                    onTap: () async {
                      CitaUser selectedUser = await matchesRepository
                          .getUserDetails(widget.selectedUser.uid);
                      CitaUser currentUser = await matchesRepository
                          .getUserDetails(widget.currentUser.uid);
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


                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(
                                              size.height * 0.02),

                                          child: iconWidget(FontAwesomeIcons.mapMarked,
                                                  () async {
                                                List<String> list1 = await _searchRepository.getUserLocations(widget.currentUser.uid.toString());
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
                                              }, size.height * .04, Colors.white),
                                      ),
                                      iconWidget(Icons.clear,
                                              () async {
                                          await matchesRepository.unmatchUser(widget.currentUser.uid, widget.selectedUser.uid);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          }, size.height * 0.06, Colors.red)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
          child:
              Container(
                height: size.height* 0.06,
                width: size.height * 0.06,
                child: PhotoWidget(
                  photoLink: widget.selectedUser.photo,
                ),
              ),
            ),),
            SizedBox(
              width: size.width * 0.03,
            ),
            Expanded(
              child: Text(widget.selectedUser.name),
            ),
    ],
        ),
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        bloc: _messagingBloc,
        builder: (BuildContext context, MessagingState state) {
          if (state is MessagingInitialState) {
            _messagingBloc.add(
              MessageStreamEvent(
                  currentUserId: widget.currentUser.uid,
                  selectedUserId: widget.selectedUser.uid),
            );
          }
          if (state is MessagingLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is MessagingLoadedState) {
            Stream<QuerySnapshot> messageStream = state.messageStream;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: messageStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        "Start the conversation?",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      );
                    }
                    if (snapshot.data.docs.isNotEmpty) {
                      return Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return MessageWidget(
                                    currentUserId: widget.currentUser.uid,
                                    messageId: snapshot
                                        .data.docs[index].id,
                                  );
                                },
                                itemCount: snapshot.data.docs.length,
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          "Start the conversation ?",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  },
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.06,
                  color: backgroundColor,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null) {
                            File photo = File(result.files.single.path);
                            _messagingBloc.add(
                              SendMessageEvent(
                                message: Message(
                                    text: null,
                                    senderName: widget.currentUser.name,
                                    senderId: widget.currentUser.uid,
                                    photo: photo,
                                    selectedUserId: widget.selectedUser.uid),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * 0.005),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: size.height * 0.04,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: size.height * 0.05,
                          padding: EdgeInsets.all(size.height * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(size.height * 0.04),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _messageTextController,
                              textInputAction: TextInputAction.send,
                              maxLines: null,
                              decoration: null,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: backgroundColor,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isValid ? _onFormSubmitted : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * 0.01),
                          child: Icon(
                            Icons.send,
                            size: size.height * 0.04,
                            color: isValid ? Colors.white : Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}