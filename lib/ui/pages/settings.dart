import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/authentication/authentication_bloc.dart';
import 'package:flutter_test2/repositories/userRepository.dart';
import 'package:flutter_test2/repositories/matchesRepository.dart';

import '../constants.dart';

class Settings extends StatefulWidget {
  final String userId;

  const Settings({this.userId});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final UserRepository _userRepository = UserRepository();
  final MatchesRepository _matchesRepository = MatchesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Text('Settings'
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: (){
                  //open edit profile
                },
                title: Text("Edit Profile") ,
                trailing: Icon(Icons.edit,color: backgroundColor,) ,
              ),
            ),
            const SizedBox(height: 10.0,),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[

                  ListTile(
                      leading: Icon(Icons.policy_outlined, color: backgroundColor,),
                      title: Text("Privacy Policy"),
                      trailing: Icon(Icons.keyboard_arrow_right,color: backgroundColor,),
                      onTap:(){
                        //open privacy policy
                      }

                  ),
                  Divider(
                    color: Colors.black,
                    indent: 20,
                    endIndent: 20,
                  ),
                  ListTile(
                      leading: Icon(Icons.delete, color: backgroundColor,),
                      title: Text("Delete Profile"),
                      trailing: Icon(Icons.keyboard_arrow_right,color: backgroundColor,),
                      onTap:() async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Profile.'),
                              content: Text("Are You Sure Want To Proceed ?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("YES"),
                                  onPressed: () async {
                                    User user = FirebaseAuth.instance.currentUser;
                                    await _matchesRepository.deleteUserFromAllMatches(user.uid);
                                    await _userRepository.deleteProfile(user.uid);
                                    user.delete();
                                    BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),

                                TextButton(
                                  child: Text("NO"),
                                  onPressed: () {
                                    //Put your code here which you want to execute on No button click.
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Text("Notification Settings", style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            ),
            SwitchListTile(value: true,
              activeColor: Colors.indigo,
              contentPadding: const EdgeInsets.all(0),
              title: Text("Receive Notifications"),
              onChanged: (val){
                // flip
              },
            ),
          ],
        ),
      ),
    );
  }
}
