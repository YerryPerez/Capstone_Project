import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test2/repositories/searchRepository.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/pages/address_search.dart';
import 'package:flutter_test2/ui/pages/place_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_test2/repositories/userRepository.dart';
import 'package:flutter_test2/models/location.dart';

class Locations extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
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
        home: MyHomePage(title: 'My Locations'),
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
  String _locationName = '';
  final UserRepository _userRepository = UserRepository();
  final SearchRepository _searchRepository = SearchRepository();

  Future<List<Location>> getLocations(SearchRepository _search) async {
    var data = await _search
        .getUserLocations(FirebaseAuth.instance.currentUser.uid.toString());

    List<Location> locations = [];

    for (var s in data) {
      List<String> locationDetails = s.split(",");
      Location localWithName = Location();
      localWithName.locationName = locationDetails[locationDetails.length-1];
      if (localWithName.locationName.length > 40){
        String s = localWithName.locationName;
        s = s.substring(0, 40);
        s = s.substring(0,s.lastIndexOf(" "));
        localWithName.locationName = s + "...";
      }
      localWithName.locationAddress = locationDetails[0]+locationDetails[1]+"\n"+locationDetails[2]+" "+locationDetails[3]+"\n";
      locations.add(localWithName);
    }
    return locations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
              _fullAddress = _streetNumber + " ," + _street + " ," + _city + " ," + _zipCode + " ," + _locationName;
            });
            User user = FirebaseAuth.instance.currentUser;
            await _userRepository.addLocationPreference(_fullAddress,
                _streetNumber, _street, _city, _zipCode, _locationName);
            // await _userRepository.addUserToLocationCollection(_fullAddress, user.uid.toString());
            await _userRepository.addLocationToUserCollection(
                _fullAddress, user.uid.toString());
            setState(() {
            });
          }
        },
        child: const Icon(Icons.add_location_alt_outlined),
        backgroundColor: Colors.green,
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
            future: getLocations(_searchRepository),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                    child: Center(child: Text("Loading Locations...")));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        child: Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            margin: const EdgeInsets.all(1.0),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children:<Widget> [
                                  Row(
                                      children:<Widget> [
                                        Text(snapshot.data[index].locationName,style: new TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,)),
                                      ]),
                                  Row(
                                      children:<Widget> [
                                        Text((snapshot.data[index].locationAddress)),
                                      ])
                                ],
                              ),)

                        )
                    );
                    // return ListTile(
                    //   title: Text(snapshot.data[index].toString()),
                    // );
                  },
                );
              }
            }),
        // ],
      ),
    );
    // );
  }
}
