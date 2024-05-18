import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/locators/service_locator.dart';
import 'package:cabdriver/providers/app_provider.dart';
import 'package:cabdriver/providers/user.dart';
import 'package:cabdriver/screens/home.dart';
import 'package:cabdriver/screens/login.dart';
import 'package:cabdriver/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>.value(
          value: AppStateProvider(),
        ),
        ChangeNotifierProvider.value(value: UserProvider.initialize()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.deepOrange),
        title: 'Flutter Taxi',
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UserProvider>(context);

    return FutureBuilder(
      // Initialize FlutterFire:
      future: initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Something went wrong')],
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          switch (auth.status) {
            case Status.Uninitialized:
              return const Splash();
            case Status.Unauthenticated:
            case Status.Authenticating:
              return const LoginScreen();
            case Status.Authenticated:
              return MyHomePage();
            default:
              return const LoginScreen();
          }
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
        );
      },
    );
  }
}
