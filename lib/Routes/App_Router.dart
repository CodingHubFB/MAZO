import 'package:MAZO/Screens/AddItemsDetails/Add_Items.dart';
import 'package:MAZO/Screens/AddItemsDetails/Edit_Items.dart';
import 'package:MAZO/Screens/Auth/CompleteProfile.dart';
import 'package:MAZO/Screens/Auth/LoginScreen.dart';
import 'package:MAZO/Screens/Auth/OTPScreen.dart';
import 'package:MAZO/Screens/CartScreen.dart';
import 'package:MAZO/Screens/Checkout.dart';
import 'package:MAZO/Screens/Checkout_Summary.dart';
import 'package:MAZO/Screens/Home/Home_Screen_Profile.dart';
import 'package:MAZO/Screens/Profile/User_Profile.dart';
import 'package:MAZO/Screens/SearchScreen.dart';
import 'package:MAZO/Screens/Shipping_Orders.dart';
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
    GoRoute(
      path: '/UserProfile',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return UserProfile(userId: params['userId']!);
      },
    ),
    GoRoute(
      path: '/UserProfileHome',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return HomeScreenProfile(
          userProfileId: params['userProfileId']!,
          itemId: params['item_id']!,
        );
      },
    ),
    GoRoute(
      path: '/EditDetailsItem',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return EditItems(itemId: params['item_id']!);
      },
    ),
    GoRoute(
      path: '/CheckoutSummary',
      builder: (context, state) => OrderSummary(),
    ),
    GoRoute(path: '/checkout', builder: (context, state) => CheckoutScreen()),
    GoRoute(path: '/shippingOrders', builder: (context, state) => ShippingOrders()),
    GoRoute(path: '/addDetails', builder: (context, state) => AddItems()),
    GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
  ],
);
