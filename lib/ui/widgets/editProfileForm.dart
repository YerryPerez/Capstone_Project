import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_test2/bloc/authentication/authentication_bloc.dart';
import 'package:flutter_test2/bloc/profile/bloc.dart';
import 'package:flutter_test2/models/citaUser.dart';

import 'package:flutter_test2/repositories/matchesRepository.dart';
import 'package:flutter_test2/repositories/userAccountRepository.dart';
import 'package:flutter_test2/repositories/userRepository.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/widgets/gender.dart';
import 'package:flutter_test2/ui/widgets/photo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class editProfileForm extends StatefulWidget {
  final UserRepository _userRepository;
   CitaUser _userAccountInfo;

  editProfileForm({@required UserRepository userRepository, @required CitaUser userAccountInfo})
      : assert(userRepository != null && userAccountInfo != null),
        _userAccountInfo = userAccountInfo,
        _userRepository = userRepository;

  @override
  _EditProfileForm createState() => _EditProfileForm();
}

class _EditProfileForm extends State<editProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final UserAccountRepository userInfoRepo = UserAccountRepository();



  String gender;
  DateTime age;
  File uploadPhotoFromPhone;
  GeoPoint location;

  ProfileBloc _profileBloc;
  String photo;
  UserRepository get _userRepository => widget._userRepository;
  CitaUser get _userAccountInfo => widget._userAccountInfo;


  bool get isFilled =>
      _nameController.text.isNotEmpty &&
      gender != null &&
      age != null;

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting;
  }

  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    location = GeoPoint(position.latitude, position.longitude);
  }
    _getCurrentDetails() async {
     _nameController.text = _userAccountInfo.name;
     age = _userAccountInfo.age.toDate();
     gender = _userAccountInfo.gender;
     photo = _userAccountInfo.photo;
    }

  _onSubmitted() async {
    await _getLocation();
    _profileBloc.add(
      Submitted(
          name: _nameController.text,
          age: age,
          location: location,
          gender: gender,
          photo: uploadPhotoFromPhone),
    );
  }

  _onSubmittedWithoutImage() async {
    await _getLocation();
    _profileBloc.add(
      SubmittedWithoutImage(
          name: _nameController.text,
          age: age,
          location: location,
          gender: gender,
          url: photo
          ),
    );
  }
  @override
  void initState() {
    _getLocation();
    _getCurrentDetails();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocListener<ProfileBloc, ProfileState>(
        // bloc: _profileBloc,
        listener: (context, state) {
      if (state.isFailure) {
        print("Failed");
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                Text('Profile Edit Unsuccessful'),
                Icon(Icons.error)
              ])));
      }
      if (state.isSubmitting) {
        print("Submitting");
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                Text('Submitting'),
                CircularProgressIndicator(),
              ])));
      }
      if (state.isSuccess) {
        print("Success");
        BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
      }
    }, child: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              color: backgroundColor,
              width: size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: size.width,
                        child: CircleAvatar(
                          radius: size.width * .3,
                          backgroundColor: Colors.transparent,
                          child: uploadPhotoFromPhone == null
                              ? GestureDetector(
                                  onTap: () async {
                                    FilePickerResult result = await FilePicker
                                        .platform
                                        .pickFiles(type: FileType.image);
                                    log("not event in there");
                                    if (result != null) {
                                      setState(() {
                                        uploadPhotoFromPhone = File(result.files.first.path);
                                      });
                                    }
                                  },
                                  //default image
                                  child:  ClipOval(
                                    child: Container(
                                      height: size.height* 0.3,
                                      width: size.height * 0.3,
                                      child: PhotoWidget(
                                        photoLink: photo,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    FilePickerResult result = await FilePicker
                                        .platform
                                        .pickFiles(type: FileType.image);
                                    log("in there");
                                    if (result != null) {
                                      setState(() {
                                        uploadPhotoFromPhone = File(result.files.first.path);
                                      });
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: size.width * .3,
                                    backgroundImage: FileImage(uploadPhotoFromPhone),
                                  )),
                        )),
                    textFieldWidget(_nameController, "Name", size),
                    GestureDetector(
                      onTap: () {
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1900, 1, 1),
                          maxTime: DateTime(DateTime.now().year - 17, 1, 1),
                          onConfirm: (date) {
                            setState(() {
                              age = date;
                            });
                            print(age);
                          },
                        );
                      },
                      child:
                      Text(
                        age == null? "Tap to enter birthday": "Birth Date: " +DateFormat.yMMMd().format(age),
                        style: TextStyle(
                            color: Colors.white, fontSize: size.width * .09),
                      )
                      ,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * .02),
                          child: Text(
                            "You are",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .09),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            genderWidget(
                                FontAwesomeIcons.venus, "Female", size, gender,
                                () {
                              setState(() {
                                gender = "Female";
                              });
                            }),
                            genderWidget(
                                FontAwesomeIcons.mars, "Male", size, gender,
                                () {
                              setState(() {
                                gender = "Male";
                              });
                            }),
                            genderWidget(FontAwesomeIcons.transgender,
                                "Transgender", size, gender, () {
                              setState(() {
                                gender = "Transgender";
                              });
                            }),
                          ],
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                      ],
                    ),
                    Padding(
                        padding:
                            EdgeInsets.all(30),
                        child: GestureDetector(
                            onTap: () {
                              if (isButtonEnabled(state)) {
                                if(uploadPhotoFromPhone==null)
                                {
                                  _onSubmittedWithoutImage();
                                }
                                else{
                                _onSubmitted();
                                }
                              } else {}
                            },
                            child: Container(
                                width: size.width * .8,
                                height: size.height * .06,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(size.height * .05),
                                ),
                                child: Center(
                                    child: Text("Save",
                                        style: TextStyle(
                                            fontSize: size.height * .025,
                                            color: Colors.blue))))))
                  ])));
    }));
  }
}

Widget textFieldWidget(controller, text, size) {
  return Padding(
    padding: EdgeInsets.all(size.height * .02),
    child: TextField(
      maxLength: 10,
      controller: controller,
      decoration: InputDecoration(
          labelText: text,
          labelStyle:
              TextStyle(color: Colors.white, fontSize: size.height * .03),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          )),
    ),
  );
}
