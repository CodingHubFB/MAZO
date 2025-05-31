import 'package:mazo/Screens/TabPaymentWebView.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int isSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/shippingOrders');
          },
          icon: Icon(Iconsax.arrow_circle_left),
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text("Payments Methods", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  isSelected = 1;
                });
              },
              tileColor: Colors.grey.shade200,
              leading: Icon(Iconsax.wallet_1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side:
                    isSelected == 1
                        ? BorderSide(color: Colors.black, width: 2)
                        : BorderSide.none,
              ),
              title: Text("Cash on Delivery"),
            ),
            SizedBox(height: 10),
            ListTile(
              onTap: () {
                setState(() {
                  isSelected = 2;
                });
              },
              tileColor: Colors.grey.shade200,
              leading: Icon(Iconsax.card),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side:
                    isSelected == 2
                        ? BorderSide(color: Colors.black, width: 2)
                        : BorderSide.none,
              ),
              title: Text("Credit Card"),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (isSelected == 1) {
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TapPaymentWebView()),
            );
          }
        },
        child: SizedBox(height: 60, child: ButtonWidget(btnText: "Pay")),
      ),
    );
  }
}
