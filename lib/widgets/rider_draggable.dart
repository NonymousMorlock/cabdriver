import 'package:cabdriver/helpers/style.dart';
import 'package:cabdriver/locators/service_locator.dart';
import 'package:cabdriver/providers/app_provider.dart';
import 'package:cabdriver/services/call_sms.dart';
import 'package:cabdriver/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiderWidget extends StatelessWidget {
  const RiderWidget({super.key});

  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.05,
      maxChildSize: 0.6,
      builder: (BuildContext context, myscrollController) {
        return Container(
          decoration: BoxDecoration(
            color: white,
//                        borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(20),
//                            topRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: grey.withOpacity(.8),
                offset: const Offset(3, 2),
                blurRadius: 7,
              ),
            ],
          ),
          child: ListView(
            controller: myscrollController,
            children: [
              const SizedBox(
                height: 12,
              ),
              ListTile(
                leading: Container(
                  child: appState.riderModel.phone == null
                      ? const CircleAvatar(
                          radius: 30,
                          child: Icon(
                            Icons.person_outline,
                            size: 25,
                          ),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(appState.riderModel.photo),
                        ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${appState.riderModel.name}\n',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: appState.rideRequestModel.destination,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                        style: const TextStyle(color: black),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _service.call(appState.riderModel.phone);
                    },
                    icon: const Icon(Icons.call),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(12),
                child: CustomText(
                  text: 'Ride details',
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 100,
                    width: 10,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 9),
                          child: Container(
                            height: 45,
                            width: 2,
                            color: primary,
                          ),
                        ),
                        const Icon(Icons.flag),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '\nPick up location \n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: '25th avenue, flutter street \n\n\n',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: 'Destination \n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: '${appState.rideRequestModel.destination} \n',
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      style: const TextStyle(color: black),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: red),
                  onPressed: () {},
                  child: const CustomText(
                    text: 'Cancel Ride',
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
