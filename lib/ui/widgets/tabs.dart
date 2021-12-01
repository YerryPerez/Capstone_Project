import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/authentication/authentication_bloc.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/pages/locations.dart';
import 'package:flutter_test2/ui/pages/matches.dart';
import 'package:flutter_test2/ui/pages/messages.dart';
import 'package:flutter_test2/ui/pages/search.dart';
import 'package:flutter_test2/ui/pages/settings.dart';

class Tabs extends StatelessWidget {
  final userId;

  const Tabs({this.userId});
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Locations(),
      Search(userId: userId,),
      Matches(userId: userId,),
      Messages( userId: userId,),
    ];

    return Theme(
      data: ThemeData(
        primaryColor: Colors.deepOrange,
        backgroundColor: Colors.deepOrange,
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepOrange,
              centerTitle: true,
              title: Text(
                "Cita",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
    showDialog(
    context: context,
    builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out'),
                      content: Text("Are you sure want to proceed?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("YES"),
                          onPressed: () async {
                            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
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
                    );});
                  },
                ),

              ],
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.0),
                  child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TabBar(indicatorColor: Colors.white,tabs: <Widget>[
                            Tab(icon: Icon(Icons.add_location)),
                            Tab(icon: Icon(Icons.search)),
                            Tab(icon: Icon(Icons.people)),
                            Tab(icon: Icon(Icons.message)),
                          ])
                        ],
                      ))),
            ),
            body: TabBarView(
              children: pages,
            )),
      ),
    );
  }
}
