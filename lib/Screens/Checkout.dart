import 'package:mazo/Core/StripeIntegration.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Screens/TabPaymentWebView.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int isSelected = 0;

  double shippingFee = 10.0;
  List cartOrders = [];
  double totalPrices = 0.0;
  double finalTotalFinish = 0.0;

  Future getCartOrders() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    var orders = await AppUtils.makeRequests(
      "fetch",
      "SELECT Cart.id AS id, Items.`name`, Items.id AS itmid,Items.price, Items.media,Items.uid, Cart.qtt FROM Cart LEFT JOIN Items ON Cart.item_id = Items.id WHERE Cart.order_id = '${prefx.getString("OID")}'",
    );

    setState(() {
      cartOrders = orders;
      totalPrices = 0.0; // لازم تصفره قبل التكرار
      for (var cartOrder in cartOrders) {
        totalPrices +=
            double.parse(cartOrder['price'].toString()) *
            double.parse(cartOrder['qtt'].toString());
      }
      finalTotalFinish = totalPrices + shippingFee;
    });
  }

  @override
  void initState() {
    getCartOrders();
    super.initState();
  }

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
            String result = await PaymentManager.makePayment(
              (finalTotalFinish * 100).toInt(),
              "qar",
            );
            if (result == 'Succeeded') {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("حالة الدفع: $result")));
              context.go('/paymentSuccess');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("حالة الدفع: $result")));
            }
          }
        },
        child: SizedBox(height: 60, child: ButtonWidget(btnText: "Pay")),
      ),
    );
  }
}
