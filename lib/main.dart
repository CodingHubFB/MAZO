import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:mazo/Core/ApiKeys.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/firebase_options.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mazo/Core/Theme.dart';
import 'package:mazo/Routes/App_Router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  // iOS settings
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  // Android settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Combined settings
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Stripe.publishableKey = ApiKeys.publishableKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? fcmToken = '';

  Future<void> showNotification(title, body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> initFCM() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    print("UIIIIIID ----> ${prefx.getString("UID")}");
    print("OIIIIIID ----> ${prefx.getString("OID")}");
    // طلب الإذن بالإشعارات
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ المستخدم وافق على الإشعارات');

      // الحصول على FCM Token
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("🔥 FCM Token: $fcmToken");
      AppUtils.makeRequests(
        "query",
        "UPDATE Users SET fcm_token = '$fcmToken' WHERE uid = '${prefx.getString("UID")}' ",
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 رسالة أثناء التشغيل: ${message.notification?.title}');
        print(message.notification?.body);
        showNotification(
          message.notification?.title,
          message.notification?.body,
        );
        // final data = message.data;
        // if (data['action'] == 'open_invoice') {
        //   print(data['orderId']);
        //   AppUtils.sNavigateToReplace(
        //     navigatorKey.currentState!.context,
        //     '/invoice',
        //     {'orderId': data['orderId']},
        //   );
        // }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // final data = message.data;
        // if (data['action'] == 'open_invoice') {
        //   print(data['orderId']);
        //   AppUtils.sNavigateToReplace(
        //     navigatorKey.currentState!.context,
        //     '/invoice',
        //     {'orderId': data['orderId']},
        //   );
        // }
      });
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      // if (initialMessage != null) {
      //   final data = initialMessage.data;
      //   if (data['action'] == 'open_invoice') {
      //     print(data['orderId']);
      //     AppUtils.sNavigateToReplace(
      //       navigatorKey.currentState!.context,
      //       '/invoice',
      //       {'orderId': data['orderId']},
      //     );
      //   }
      // }
    } else {
      print('❌ المستخدم رفض الإشعارات');
    }
  }

  @override
  void initState() {
    initFCM();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MAZO',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
