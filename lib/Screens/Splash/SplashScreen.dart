import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:mazo/Core/Theme.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String lang = "eng";
  List languages = [];

  Future getLang() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();

    setState(() {
      lang = prefx.getString("Lang")!;
      getLangDB();
    });
  }

  Future getLangDB() async {
    var results = await AppUtils.makeRequests(
      "fetch",
      "SELECT $lang FROM Languages ",
    );
    setState(() {
      languages = results;
    });
  }

  @override
  void initState() {
    getLang();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/home'); // التنقل باستخدام GoRouter
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return languages.isEmpty ? Scaffold() : Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/img/Logo.png", width: 170),
            const SizedBox(height: 20),
            Text(languages[0][lang] ?? "", style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            SpinKitDoubleBounce(color: AppTheme.primaryColor, size: 30.0),
          ],
        ),
      ),
    );
  }
}
