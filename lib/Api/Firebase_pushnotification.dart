import 'dart:convert';

import 'package:VenueVerse/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("notiiii");
  print(message.notification?.title);

  print(message.notification?.body);

  print(message.data);
}

class Firebasepushnotification {
  final _firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _androidchannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notification',
      description: "this channel is used for important notification to user",
      importance: Importance.defaultImportance);
  void handleMessage(RemoteMessage? message) {
    // print("navi");
    // navigatorkey.currentState?.pushNamed('/newrequest', arguments: message);
  }
  final _localNotification = FlutterLocalNotificationsPlugin();
  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((Message) {
      final notification = Message.notification;
      if (notification == null) return;
      _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  _androidchannel.id, _androidchannel.name,
                  channelDescription: _androidchannel.description,
                  icon: '@drawable/ic_launcher')),
          payload: jsonEncode(Message.toMap()));
    });
  }

  Future initLocalNotification() async {
    const IOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawble/ic_launcher');
    const setting = InitializationSettings(android: android, iOS: IOS);
    await _localNotification.initialize(setting,
        onDidReceiveBackgroundNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
      handleMessage(message);
    });
    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidchannel);
  }

  Future<void> initNotification({required uid}) async {
    await _firebaseMessaging.requestPermission();
    final fcmtoken = await _firebaseMessaging.getToken();
    CollectionReference _cat = _firestore.collection("Userdetails");
    Query query = _cat.where("uid", isEqualTo: uid);
    QuerySnapshot querySnapshot = await query.get();
    print("fcm");
    print(fcmtoken.toString());
    final _docData = querySnapshot.docs.map((doc) => doc.id).toList();
    if (_docData.isNotEmpty) {
      await _firestore
          .collection("Userdetails")
          .doc(_docData[0])
          .update({"fcm": fcmtoken.toString()}).catchError((e) => {print(e)});
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotification();
    initLocalNotification();
  }
}
