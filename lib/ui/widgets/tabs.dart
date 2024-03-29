import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/authentication/authentication_bloc.dart';
import 'package:flutter_test2/ui/constants.dart';
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
      Search(userId: userId,),
      Matches(userId: userId,),
      Messages( userId: userId,),
    ];

    return Theme(
      data: ThemeData(
        primaryColor: backgroundColor,
        accentColor: Colors.white,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
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
                    BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
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
                          TabBar(tabs: <Widget>[
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
