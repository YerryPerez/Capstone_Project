import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/profile/bloc.dart';
import 'package:flutter_test2/repositories/userRepository.dart';
import 'package:flutter_test2/ui/constants.dart';
import 'package:flutter_test2/ui/widgets/editProfileForm.dart';
import 'package:flutter_test2/ui/widgets/profileForm.dart';

class EditProfile extends StatelessWidget {
  final _userRepository;


  EditProfile({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(userRepository: _userRepository),
            child: editProfileForm(userRepository: _userRepository,

      ),
      ),
    );
  }
}
