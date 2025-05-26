import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
              tileColor: Colors.grey.shade200,
              leading: Icon(Iconsax.wallet_1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              title: Text("Cash on Delivery"),
            ),
            SizedBox(height: 10),
            ListTile(title: Text("Cash on Delivery")),
          ],
        ),
      ),
    );
  }
}
