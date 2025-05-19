import 'dart:math';

import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Widgets/Back_Button.dart';
import 'package:MAZO/Widgets/Button_Widget.dart';
import 'package:MAZO/Widgets/OTP_Widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String? mobile;
  final int? otp;
  const OTPScreen({super.key, this.mobile, this.otp});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isValid = false;
  @override
  Widget build(BuildContext context) {
    otpController.text = widget.otp.toString();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        "assets/img/Logo.png",
                        width: MediaQuery.sizeOf(context).width / 2,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Enter your OTP",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    OtpWidget(
                      otpController: otpController,
                      otpChanged: (val) {
                        setState(() {
                          isValid = val.length == 6;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: GestureDetector(
                        onTap: () async {
                          SharedPreferences prefx =
                              await SharedPreferences.getInstance();
                          var users = await AppUtils.makeRequests(
                            "fetch",
                            "SELECT uid FROM Users WHERE PhoneNumber = '${widget.mobile}'",
                          );

                          if (users[0] != null) {
                            await prefx.setString('UID', users[0]['uid']);
                            context.go("/splash");
                          } else {
                            AppUtils.sNavigateToReplace(
                              context,
                              '/createUser',
                              {'phonenumber': widget.mobile!},
                            );
                          }
                        },
                        child: ButtonWidget(
                          isDisabled: true,
                          btnText: "Send Otp",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: InkWell(
              onTap: () {
                context.go('/login');
              },
              child: RectButtonWidget(
                bicon: Iconsax.arrow_circle_left,
                bsize: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
