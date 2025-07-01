import 'package:mazo/Screens/AddItemsDetails/Add_Items.dart';
import 'package:mazo/Screens/AddItemsDetails/Edit_Items.dart';
import 'package:mazo/Screens/Auth/CompleteProfile.dart';
import 'package:mazo/Screens/Auth/LoginScreen.dart';
import 'package:mazo/Screens/Auth/OTPScreen.dart';
import 'package:mazo/Screens/CartScreen.dart';
import 'package:mazo/Screens/ChangeLanguage.dart';
import 'package:mazo/Screens/ChatScreen.dart';
import 'package:mazo/Screens/Checkout.dart';
import 'package:mazo/Screens/Checkout_Summary.dart';
import 'package:mazo/Screens/CustomerOrders.dart';
import 'package:mazo/Screens/ForceUpdateScreen.dart';
import 'package:mazo/Screens/Home/Home_Screen_Profile.dart';
import 'package:mazo/Screens/InvoiceWebView.dart';
import 'package:mazo/Screens/PaymentSuccess.dart';
import 'package:mazo/Screens/Profile/User_Profile.dart';
import 'package:mazo/Screens/SearchScreen.dart';
import 'package:mazo/Screens/Shipping_Orders.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mazo/Screens/Home/Home_Screen.dart';
import 'package:mazo/Screens/Splash/SplashScreen.dart';
import 'package:mazo/Screens/accessBlock.dart';
import 'package:mazo/Screens/payGoogleForms.dart';
import 'package:mazo/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('Lang');

    if (lang == null && state.matchedLocation != '/changeLanguage') {
      return '/changeLanguage';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/block', builder: (context, state) => const AccessBlock()),
    GoRoute(
      path: '/changeLanguage',
      builder: (context, state) => const ChangeLangScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/test', builder: (context, state) => TestScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
    GoRoute(
      path: '/force-update',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ForceUpdateScreen(
          message: data['message'],
          storeUrl: data['storeUrl'],
        );
      },
    ),

    GoRoute(
      path: '/customersOrders',
      builder: (context, state) {
        final custId = (state.extra as Map?)?['custId'] ?? '';
        return CustomersOrders(custId: custId);
      },
    ),

    // GoRoute(
    //   path: '/payGoogleForm',
    //   builder: (context, state) {
    //     final totalAmount = (state.extra as Map?)?['totalAmount'] ?? '';
    //     return PayGoogleForms(totalAmount: totalAmount);
    //   },
    // ),

    GoRoute(
      path: '/invoice',
      builder: (context, state) {
        final orderId = (state.extra as Map?)?['orderId'] ?? '';
        final payment = (state.extra as Map?)?['payment'] ?? '';
        final shipId = (state.extra as Map?)?['shipId'] ?? '';
        final custId = (state.extra as Map?)?['custId'] ?? '';
        return InvoiceWebView(
          orderId: orderId,
          payment: payment,
          shipId: shipId,
          custId: custId,
        );
      },
    ),

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
      path: '/Globee/product',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        print('وصل للـ Route بتاع المنتج، ID = $id');
        return HomeScreen(productId: id);
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
      path: '/chatSeller',
      builder: (context, state) {
        final params = state.extra as Map<String, String>;
        return ChatScreen(
          chatId: params['chatId']!,
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
    GoRoute(
      path: '/paymentSuccess',
      builder: (context, state) => const PaymentSuccess(),
    ),

    // GoRoute(path: '/checkout', builder: (context, state) => CheckoutScreen()),
    GoRoute(
      path: '/shippingOrders',
      builder: (context, state) => ShippingOrders(),
    ),
    GoRoute(path: '/addDetails', builder: (context, state) => AddItems()),
    GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
  ],
);
