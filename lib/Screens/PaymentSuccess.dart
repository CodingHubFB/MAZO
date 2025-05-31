import 'dart:math';

import 'package:flutter/material.dart';
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
  }

  @override
  void initState() {
    renewOID();
    super.initState();
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
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text("Payment Successful!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            const Text("Thank you for your purchase."),
          ],
        ),
      ),
    );
  }
}
