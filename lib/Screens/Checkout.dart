import 'package:mazo/Core/PushNotificationsServiceOrders.dart';
import 'package:mazo/Core/StripeIntegration.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/Widgets/Button_Widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:provider/provider.dart';
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
          SharedPreferences prefx = await SharedPreferences.getInstance();

          if (isSelected == 1) {
            // طريقة الدفع: عند الاستلام
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "جارٍ تأكيد الدفع ومعالجة الطلب...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );

            // هات البائعين الفريدين
            final Set<dynamic> sellerUids =
                cartOrders.map((order) => order['uid']).toSet();

            // هات اسم العميل
            var customerName = await AppUtils.makeRequests(
              "fetch",
              "SELECT Fullname FROM Users WHERE uid = '${prefx.getString("UID")}'",
            );
            if (customerName is Map<String, dynamic>) {
              customerName = [customerName];
            }

            for (var sellerUid in sellerUids) {
              // فلترة المنتجات الخاصة بالبائع ده فقط
              final sellerProducts =
                  cartOrders.where((e) => e['uid'] == sellerUid).toList();

              // إضافة Order جديد للبائع
              await AppUtils.makeRequests(
                "query",
                "INSERT INTO Orders VALUES (NULL, '$sellerUid', '${prefx.getString("UID")}', '${prefx.getString("OID")}', '${Provider.of<AppProvider>(context, listen: false).shipId}', '${DateTime.now().toString()}', 'pending')",
              );

              // ابعت إشعار للبائع
              var results = await AppUtils.makeRequests(
                "fetch",
                "SELECT fcm_token FROM Users WHERE uid = '$sellerUid'",
              );

              if (results is Map<String, dynamic>) {
                results = [results];
              }

              for (var result in results) {
                PushNotificationServiceOrders.sendNotificationToUser(
                  result['fcm_token'],
                  "New Order from a Customer (${customerName[0]['Fullname']})",
                  "One of your products has been purchased. Please check the order details and deliver it as soon as possible.",
                  prefx
                      .getString("OID")
                      .toString(), // ده ممكن تستبدله بالـ order_id الجديد لو محتاجه
                );
              }
            }

            context.go('/paymentSuccess');
          } else {
            // طريقة الدفع: كارت
            String result = await PaymentManager.makePayment(
              (finalTotalFinish * 100).toInt(),
              "qar",
            );

            if (result == 'Succeeded') {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("حالة الدفع: $result")));

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            "جارٍ تأكيد الدفع ومعالجة الطلب...",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

              // هات البائعين الفريدين
              final Set<dynamic> sellerUids =
                  cartOrders.map((order) => order['uid']).toSet();

              // هات اسم العميل
              var customerName = await AppUtils.makeRequests(
                "fetch",
                "SELECT Fullname FROM Users WHERE uid = '${prefx.getString("UID")}'",
              );
              if (customerName is Map<String, dynamic>) {
                customerName = [customerName];
              }

              for (var sellerUid in sellerUids) {
                // فلترة المنتجات الخاصة بالبائع ده فقط
                final sellerProducts =
                    cartOrders.where((e) => e['uid'] == sellerUid).toList();

                // إضافة Order جديد للبائع
                await AppUtils.makeRequests(
                  "query",
                  "INSERT INTO Orders VALUES (NULL, '$sellerUid', '${prefx.getString("UID")}', '${prefx.getString("OID")}', '${Provider.of<AppProvider>(context, listen: false).shipId}', '${DateTime.now().toString()}', 'pending')",
                );

                // ابعت إشعار للبائع
                var results = await AppUtils.makeRequests(
                  "fetch",
                  "SELECT fcm_token FROM Users WHERE uid = '$sellerUid'",
                );

                if (results is Map<String, dynamic>) {
                  results = [results];
                }

                for (var result in results) {
                  PushNotificationServiceOrders.sendNotificationToUser(
                    result['fcm_token'],
                    "New Order from a Customer (${customerName[0]['Fullname']})",
                    "One of your products has been purchased. Please check the order details and deliver it as soon as possible.",
                    prefx.getString("OID").toString(),
                  );
                }
              }

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
