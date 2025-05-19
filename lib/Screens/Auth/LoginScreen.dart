import 'dart:math';

import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Screens/Auth/OTPScreen.dart';
import 'package:MAZO/Widgets/Back_Button.dart';
import 'package:MAZO/Widgets/Button_Widget.dart';
import 'package:MAZO/Widgets/Input_Widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  bool isValid = false;
  int otp = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.go('/home');
                  },
                  child: RectButtonWidget(bicon: Iconsax.arrow_circle_left),
                ),
                SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    "assets/img/Logo.png",
                    width: MediaQuery.sizeOf(context).width / 2,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Enter Phone Number",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                InputWidget(
                  iMaxLength: 8,
                  ikeyboardType: TextInputType.number,
                  icontroller: mobileController,
                  iHint: "Phone Number",
                  ichanged: (val) {
                    setState(() {
                      isValid = val.length == 8;
                    });
                  },
                  isuffixIcon: Icon(
                    isValid ? Iconsax.tick_circle : Iconsax.close_circle,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: GestureDetector(
                    onTap: () async {
                      if (isValid) {
                        int otp = 100000 + Random().nextInt(999999);
                        AppUtils.sNavigateToReplace(context, '/otp', {
                          'mobile': mobileController.text,
                          'otp': otp.toString(),
                        });
                      } else {
                        AppUtils.snackBarShowing(
                          context,
                          "Please Enter Your Mobile.",
                        );
                      }
                    },
                    child: ButtonWidget(
                      isDisabled: isValid,
                      btnText: "Send Otp",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
