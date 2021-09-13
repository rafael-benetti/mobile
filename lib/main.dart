import 'package:black_telemetry/src/core/providers/notifications_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'src/app.dart';
import 'src/locator.dart';

void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(
      NotificationsProvider().firebaseMessagingBackgroundHandler);
  Intl.defaultLocale = 'pt_BR';
  runApp(App());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
