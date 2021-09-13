import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../../interface/pages/home/home_page_model.dart';
import '../../locator.dart';
import '../services/interface_service.dart';
import 'groups_provider.dart';

class NotificationsProvider extends ChangeNotifier {
  final groupsProvider = locator<GroupsProvider>();
  final interfaceService = locator<InterfaceService>();
  String deviceToken;

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    final interfaceService = locator<InterfaceService>();

    if (message.notification != null) {
      await interfaceService.showDialogMessage(
        title: message.notification.title,
        message: message.notification.body,
      );
    }
  }

  Future<void> init() async {
    // await Firebase.initializeApp();
    // final messaging = FirebaseMessaging.instance;
    // var settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    // deviceToken = await messaging.getToken();

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     HomePageModel().riseNotificationsPage();
    //   }
    // });
  }
}
