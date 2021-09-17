import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test2/bloc/authentication/authentication_bloc.dart';
import 'package:flutter_test2/bloc/login/bloc.dart';
import 'package:flutter_test2/repositories/userRepository.dart';
import 'package:flutter_test2/ui/pages/signUp.dart';

import '../constants.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginForm({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);

    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);

    super.initState();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(PasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
          email: _emailController.text, password: _passwordController.text),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(state.error),
                Icon(Icons.error, color: Colors.red,),
              ],
            )));
        }
        if (state.isSubmitting) {

          print("isSubmitting");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Logging In..."),
                CircularProgressIndicator(),
              ],
            )));
        }
        if (state.isSuccess) {
          print("Success");
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
                color: backgroundColor,
                width: size.width,
                height: size.height,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text("Cita",
                            style: TextStyle(
                                fontSize: size.width * 0.2,
                                color: Colors.white)),
                      ),
                      Container(
                        width: size.width * 0.8,
                        child: Divider(
                          height: size.height * .05,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.height * .02),
                        child: TextFormField(
                          controller: _emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (_) {
                            return !state.isEmailValid ? "Invalid Email" : null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * .03),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.height * .02),
                        child: TextFormField(
                          controller: _passwordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          autocorrect: false,
                          obscureText: true,
                          validator: (_) {
                            return !state.isPasswordValid
                                ? "Invalid Password"
                                : null;
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * .03),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.height * 0.02),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: isLoginButtonEnabled(state)
                                  ? _onFormSubmitted
                                  : null,
                              child: Container(
                                width: size.width * .8,
                                height: size.height * .06,
                                decoration: BoxDecoration(
                                  color: isLoginButtonEnabled(state)
                                      ? Colors.white
                                      : Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(size.height * .05),
                                ),
                                child: Center(
                                    child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: size.height * .025,
                                      color: Colors.blue),
                                )),
                              ),
                            ),
                            SizedBox(
                              height: size.height * .02,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return SignUp(
                                        userRepository: _userRepository,
                                      );
                                    }),
                                  );
                                },
                                child: Text("Are you new? Create an Account",
                                    style: TextStyle(
                                      fontSize: size.height * .025,
                                      color: Colors.white,
                                    )))
                          ],
                        ),
                      ),
                    ])),
          );
        },
      ),
    );
  }
}
