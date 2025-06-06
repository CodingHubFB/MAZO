import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Routes/App_Router.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({super.key});

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  Future renewOID() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    int oid = 1000 + Random().nextInt(9999);
    setState(() {
      prefx.setString("OID", oid.toString());
    });
    await AppUtils.makeRequests(
      "query",
      "UPDATE Users SET oid = '${prefx.getString("OID")}' WHERE uid = '${prefx.getString("UID")}' ",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Success"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.tick_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text("Payment Successful!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            const Text("Thank you for your purchase."),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        renewOID();
                        context.go('/home');
                      },
                      child: ButtonWidget(btnText: "Back to Home"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences prefx =
                            await SharedPreferences.getInstance();
                        AppUtils.sNavigateToReplace(
                          navigatorKey.currentState!.context,
                          '/invoice',
                          {
                            'orderId': prefx.getString("OID").toString(),
                            'payment': 'Customer',
                          },
                        );
                      },
                      child: ButtonWidget(btnText: "Print Invoice"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
