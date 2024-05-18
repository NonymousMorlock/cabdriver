import 'package:cabdriver/helpers/screen_navigation.dart';
import 'package:cabdriver/helpers/style.dart';
import 'package:cabdriver/helpers/utils.dart';
import 'package:cabdriver/providers/app_provider.dart';
import 'package:cabdriver/providers/user.dart';
import 'package:cabdriver/screens/home.dart';
import 'package:cabdriver/screens/login.dart';
import 'package:cabdriver/widgets/custom_text.dart';
import 'package:cabdriver/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    final app = Provider.of<AppStateProvider>(context);

    return Scaffold(
      key: _key,
      backgroundColor: Colors.deepOrange,
      body: authProvider.status == Status.Authenticating
          ? const Loading()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    color: white,
                    height: 100,
                  ),
                  Container(
                    color: white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'images/lg.png',
                          width: 230,
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    color: white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: authProvider.name,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: white),
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: white),
                            labelText: 'Name',
                            hintText: 'eg: Santos Enoque',
                            icon: Icon(
                              Icons.person,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: authProvider.email,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: white),
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: white),
                            labelText: 'Email',
                            hintText: 'santos@enoque.com',
                            icon: Icon(
                              Icons.email,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: authProvider.phone,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: white),
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: white),
                            labelText: 'Phone',
                            hintText: '+91 3213452',
                            icon: Icon(
                              Icons.phone,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          controller: authProvider.password,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: white),
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: white),
                            labelText: 'Password',
                            hintText: 'at least 6 digits',
                            icon: Icon(
                              Icons.lock,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () async {
                        if (app.position == null ||
                            !await authProvider.signUp(app.position!)) {
                          Utils.showSnackBar(
                            context,
                            message: 'Registration failed!',
                          );
                          return;
                        } else {
                          Utils.showSnackBar(
                            context,
                            message: 'Registration successful!',
                          );
                        }
                        authProvider.clearController();
                        changeScreenReplacement(context, const MyHomePage());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CustomText(
                                text: 'Register',
                                color: white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      changeScreen(context, const LoginScreen());
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomText(
                          text: 'Login here',
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
