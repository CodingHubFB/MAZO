import 'dart:math';

import 'package:MAZO/Core/Utils.dart';
import 'package:MAZO/Widgets/Back_Button.dart';
import 'package:MAZO/Widgets/Button_Widget.dart';
import 'package:MAZO/Widgets/OTP_Widget.dart';
import 'package:dio/dio.dart';
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

  Future<void> getSMS() async {
    try {
      final response = await Dio().get(
        "https://connectsms.vodafone.com.qa/SMSConnect/SendServlet?application=http_gw1597&password=my3jjtap&content=${widget.otp} is Your Verification Code. Don't Share it with anyone&destination=974${widget.mobile}&source=97668&mask=GoldenEagle",
      );
      if (response.statusCode == 200) {
        print("SMS sent successfully");
      } else {
        print("Failed to send SMS: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  @override
  void initState() {
    getSMS();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                            "SELECT uid, oid FROM Users WHERE PhoneNumber = '${widget.mobile}'",
                          );

                          if (otpController.text == widget.otp.toString()) {
                            if (users[0] != null) {
                              await prefx.setString('UID', users[0]['uid']);
                              await prefx.setString('OID', users[0]['oid']);
                              context.go("/splash");
                            } else {
                              AppUtils.sNavigateToReplace(
                                context,
                                '/createUser',
                                {'phonenumber': widget.mobile!},
                              );
                            }
                          } else {
                            AppUtils.snackBarShowing(
                              context,
                              "Otp is Not Correct",
                            );
                          }
                        },
                        child: ButtonWidget(
                          isDisabled: true,
                          btnText: "Continue",
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
