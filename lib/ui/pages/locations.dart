import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/pages/address_search.dart';
import 'package:flutter_test2/ui/pages/place_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_test2/repositories/userRepository.dart';

class Location extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus){
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Locations',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: backgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Search For Locations'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String _fullAddress = '';
  String _locationName ='';
  final UserRepository _userRepository = UserRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              readOnly: true,
              onTap: () async {
                // generate a new token here
                final sessionToken = Uuid().v4();
                final Suggestion result = await showSearch(
                  context: context,
                  delegate: AddressSearch(sessionToken),
                );
                // This will change the text displayed in the TextField
                if (result != null) {
                  final placeDetails = await PlaceApiProvider(sessionToken)
                      .getPlaceDetailFromId(result.placeId);
                  setState(() {
                    _controller.text = result.description;
                    _streetNumber = placeDetails.streetNumber;
                    _street = placeDetails.street;
                    _city = placeDetails.city;
                    _zipCode = placeDetails.zipCode;
                    _locationName = placeDetails.name;
                    _fullAddress = _streetNumber + " ," + _street + " ," + _city + " ," + _zipCode + " ," +_locationName;
                  });
                  User user = FirebaseAuth.instance.currentUser;
                  await _userRepository.addLocationPreference(_fullAddress, _streetNumber, _street, _city, _zipCode,_locationName);
                  // await _userRepository.addUserToLocationCollection(_fullAddress, user.uid.toString());
                  await _userRepository.addLocationToUserCollection(_fullAddress, user.uid.toString());
                }
              },
              decoration: InputDecoration(
                icon: Container(
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.pin_drop,
                    color: Colors.black,
                  ),
                ),
                hintText: "Search Here",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
              ),
            ),
            SizedBox(height: 20.0),
            Text('Street Number: $_streetNumber'),
            Text('Street: $_street'),
            Text('City: $_city'),
            Text('ZIP Code: $_zipCode'),
            Text('Location Name: $_locationName')
          ],
        ),
      ),
    );
  }
}