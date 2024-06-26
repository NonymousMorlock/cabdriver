import 'package:cabdriver/helpers/constants.dart';
import 'package:cabdriver/helpers/screen_navigation.dart';
import 'package:cabdriver/helpers/stars_method.dart';
import 'package:cabdriver/helpers/style.dart';
import 'package:cabdriver/providers/app_provider.dart';
import 'package:cabdriver/providers/user.dart';
import 'package:cabdriver/screens/login.dart';
import 'package:cabdriver/screens/ride_request.dart';
import 'package:cabdriver/widgets/custom_text.dart';
import 'package:cabdriver/widgets/loading.dart';
import 'package:cabdriver/widgets/rider_draggable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _deviceToken();
    _updatePosition();
  }

  _deviceToken() async {
    final preferences = await SharedPreferences.getInstance();
    final user = context.read<UserProvider>();

    if (user.userModel?.token != preferences.getString('token')) {
      context.read<UserProvider>().saveDeviceToken();
    }
  }

  _updatePosition() async {
    //    this section down here will update the drivers current position on the DB when the app is opened
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    final user = Provider.of<UserProvider>(context, listen: false);
    final app = Provider.of<AppStateProvider>(context, listen: false);
    user.updateUserData({'id': id, 'position': app.position?.toJson()});
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    final Widget home = SafeArea(
      child: Scaffold(
        key: scaffoldState,
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: CustomText(
                  text: userProvider.userModel?.name ?? '',
                  size: 18,
                  weight: FontWeight.bold,
                ),
                accountEmail: CustomText(
                  text: userProvider.userModel?.email ?? '',
                ),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: CustomText(text: 'Log out'),
                onTap: () {
                  userProvider.signOut();
                  changeScreenReplacement(context, const LoginScreen());
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            MapScreen(scaffoldState),
            Positioned(
              top: 60,
              left: MediaQuery.of(context).size.width / 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: grey, blurRadius: 17)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: userProvider.userModel?.photo == null
                              ? const CircleAvatar(
                                  radius: 30,
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 25,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    userProvider.userModel!.photo,
                                  ),
                                ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: userProvider.userModel!.name,
                                size: 18,
                                weight: FontWeight.bold,
                              ),
                              stars(
                                rating: userProvider.userModel?.rating ?? 0,
                                votes: userProvider.userModel?.votes ?? 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //  ANCHOR Draggable DRIVER
            Visibility(
              visible: appState.show == Show.RIDER,
              child: RiderWidget(),
            ),
          ],
        ),
      ),
    );

    switch (appState.hasNewRideRequest) {
      case false:
        return home;
      case true:
        return const RideRequestScreen();
      default:
        return home;
    }
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen(this.scaffoldState, {super.key});

  final GlobalKey<ScaffoldState> scaffoldState;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController destinationController = TextEditingController();
  Color darkBlue = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();
  String position = 'postion';

  @override
  void initState() {
    super.initState();
    scaffoldSate = widget.scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return appState.center == null
        ? const Loading()
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: appState.center!,
                  zoom: 15,
                ),
                onMapCreated: appState.onCreate,
                myLocationEnabled: true,
                compassEnabled: false,
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.poly,
              ),
              Positioned(
                top: 10,
                left: 15,
                child: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: primary,
                    size: 30,
                  ),
                  onPressed: scaffoldSate.currentState?.openDrawer,
                ),
              ),
            ],
          );
  }
}
