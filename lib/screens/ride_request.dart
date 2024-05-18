import 'package:cabdriver/helpers/stars_method.dart';
import 'package:cabdriver/helpers/style.dart';
import 'package:cabdriver/providers/app_provider.dart';
import 'package:cabdriver/providers/user.dart';
import 'package:cabdriver/widgets/custom_btn.dart';
import 'package:cabdriver/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  _RideRequestScreenState createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppStateProvider>(context, listen: false);
    state.listenToRequest(id: state.rideRequestModel.id, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          centerTitle: true,
          title: const CustomText(
            text: 'New Ride Request',
            size: 19,
            weight: FontWeight.bold,
          ),
        ),
        backgroundColor: white,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(appState.riderModel.photo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: appState.riderModel.name ?? 'Nada'),
                ],
              ),
              const SizedBox(height: 10),
              stars(
                rating: appState.riderModel.rating,
                votes: appState.riderModel.votes,
              ),
              const Divider(),
              const ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Destiation',
                      color: grey,
                    ),
                  ],
                ),
                subtitle: ElevatedButton.icon(
                  onPressed: () async {
                    final destinationCoordiates = LatLng(
                      appState.rideRequestModel.dLatitude,
                      appState.rideRequestModel.dLongitude,
                    );
                    appState.addLocationMarker(
                      destinationCoordiates,
                      appState.rideRequestModel.destination ?? 'Nada',
                      'Destination Location',
                    );
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SizedBox(
                          height: 400,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: destinationCoordiates,
                              zoom: 13,
                            ),
                            onMapCreated: appState.onCreate,
                            myLocationEnabled: true,
                            compassEnabled: false,
                            markers: appState.markers,
                            onCameraMove: appState.onCameraMove,
                            polylines: appState.poly,
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.location_on,
                  ),
                  label: CustomText(
                    text: appState.rideRequestModel.destination ?? 'Nada',
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.flag),
                    label: const Text('User is near by'),
                  ),
                  ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.attach_money),
                    label: Text(
                      '${appState.rideRequestModel.distance.value / 500} ',
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomBtn(
                    text: 'Accept',
                    onTap: () async {
                      if (appState.requestModelFirebase.status != 'pending') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ), //this right here
                              child: const SizedBox(
                                height: 200,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'Sorry! Request Expired',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        appState.clearMarkers();

                        appState.acceptRequest(
                          requestId: appState.rideRequestModel.id,
                          driverId: userProvider.userModel.id,
                        );
                        appState.changeWidgetShowed(showWidget: Show.RIDER);
                        appState.sendRequest(
                          coordinates:
                              appState.requestModelFirebase.getCoordinates(),
                        );
//                      showDialog(
//                          context: context,
//                          builder: (BuildContext context) {
//                            return Dialog(
//                              shape: RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(
//                                      20.0)), //this right here
//                              child: Container(
//                                height: 200,
//                                child: Padding(
//                                  padding: const EdgeInsets.all(12.0),
//                                  child: Column(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.start,
//                                    children: [
//                                      SpinKitWave(
//                                        color: black,
//                                        size: 30,
//                                      ),
//                                      SizedBox(
//                                        height: 10,
//                                      ),
//                                      Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.center,
//                                        children: [
//                                          CustomText(
//                                              text:
//                                                  "Awaiting rider confirmation"),
//                                        ],
//                                      ),
//                                      SizedBox(
//                                        height: 30,
//                                      ),
//                                      LinearPercentIndicator(
//                                        lineHeight: 4,
//                                        animation: true,
//                                        animationDuration: 100000,
//                                        percent: 1,
//                                        backgroundColor:
//                                            Colors.grey.withOpacity(0.2),
//                                        progressColor: Colors.deepOrange,
//                                      ),
//                                      SizedBox(
//                                        height: 20,
//                                      ),
//                                      Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.center,
//                                        children: [
//                                          FlatButton(
//                                              onPressed: () {
//                                                appState.cancelRequest(requestId: appState.rideRequestModel.id);
//                                              },
//                                              child: CustomText(
//                                                text: "Cancel",
//                                                color: Colors.deepOrange,
//                                              )),
//                                        ],
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              ),
//                            );
//                          });
                      }
                    },
                    bgColor: green,
                    shadowColor: Colors.greenAccent,
                  ),
                  CustomBtn(
                    text: 'Reject',
                    onTap: () {
                      appState.clearMarkers();
                      appState.changeRideRequestStatus();
                    },
                    bgColor: red,
                    shadowColor: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
