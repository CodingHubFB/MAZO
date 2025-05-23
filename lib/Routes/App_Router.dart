import 'package:MAZO/Screens/AddItemsDetails/Add_Items.dart';
import 'package:MAZO/Screens/Auth/CompleteProfile.dart';
import 'package:MAZO/Screens/Auth/LoginScreen.dart';
import 'package:MAZO/Screens/Auth/OTPScreen.dart';
import 'package:MAZO/Screens/SearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:MAZO/Screens/Home/Home_Screen.dart';
import 'package:MAZO/Screens/Splash/SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return OTPScreen(
          mobile: params['mobile']!,
          otp: int.parse(params['otp'].toString()),
        );
      },
    ),

    GoRoute(
      path: '/createUser',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return CreateUser(phonenumber: params['phonenumber']!);
      },
    ),
    GoRoute(path: '/addDetails', builder: (context, state) => AddItems()),
  ],
);
