import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:barberapp/firebase_options.dart';
import 'package:barberapp/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeDateFormatting();

  // ตั้งค่าการแจ้งเตือน
  await initializeLocalNotifications();

  // ร้องขออนุญาตการแจ้งเตือน
  await requestPermission();

  // ตั้งค่าการจัดการข้อความเมื่อแอปอยู่ในพื้นหลัง
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) => _firebaseShowLocalNotification(message),
  );

  runApp(const MyApp());
}

// ฟังก์ชันสำหรับการตั้งค่าแจ้งเตือนท้องถิ่น
Future<void> initializeLocalNotifications() async {
  // ร้องขอ Permission
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// ฟังก์ชันสำหรับการร้องขออนุญาตการแจ้งเตือน
Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User denied permission');
  }
}

// ฟังก์ชันสำหรับจัดการการแจ้งเตือนเมื่อแอปอยู่ในพื้นหลัง
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // แสดงการแจ้งเตือนเมื่อแอปอยู่ในพื้นหลัง
  await showLocalNotification(
      message.notification?.title, message.notification?.body);
}

// ฟังก์ชันแสดงการแจ้งเตือน
Future<void> showLocalNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<void> _firebaseShowLocalNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber App',
      theme: ThemeData(
        // This is the theme of your application
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FlutterSplashScreen.scale(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 244, 242, 240),
            Color.fromARGB(255, 244, 242, 240),
          ],
        ),
        childWidget: SizedBox(
          child: Image.asset("assets/icons/barbersceen.gif"),
        ),
        duration: const Duration(milliseconds: 1800),
        animationDuration: const Duration(milliseconds: 1000),
        nextScreen: LoginPage(),
      ),
    );
  }
}
