import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
    // this callback is used when the app runs on the foreground
    FirebaseMessaging.onBackgroundMessage(handleOnResume);
    // used when the app is closed completely and is launched using the notification
    FirebaseMessaging.onMessage.listen(handleOnMessage);
    // when its on the background and opened using the notification drawer
    FirebaseMessaging.onMessageOpenedApp.listen(handleOnLaunch);
//      this callback is used when the app runs on the foreground
//         onMessage: handleOnMessage,
//        used when the app is closed completely and is launched using the notification
//         onLaunch: handleOnLaunch,
//        when its on the background and opened using the notification drawer
//         onResume: handleOnResume);
  }

  Future handleOnMessage(RemoteMessage message) async {
    print('=== data = ${message.data}');
  }

  Future handleOnLaunch(RemoteMessage message) async {
    print('=== data = ${message.data}');
  }

  Future handleOnResume(RemoteMessage message) async {
    print('=== data = ${message.data}');
  }
}
