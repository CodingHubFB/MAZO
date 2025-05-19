import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:MAZO/Core/Theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/home'); // التنقل باستخدام GoRouter
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/img/Logo.png", width: 170),
            const SizedBox(height: 20),
            Text('MAZO', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            SpinKitDoubleBounce(color: AppTheme.primaryColor, size: 30.0),
          ],
        ),
      ),
    );
  }
}
