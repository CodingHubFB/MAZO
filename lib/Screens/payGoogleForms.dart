import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mazo/Core/PushNotificationsServiceOrders.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayGoogleForms extends StatefulWidget {
  final String totalAmount;
  const PayGoogleForms({super.key, required this.totalAmount});

  @override
  State<PayGoogleForms> createState() => _PayGoogleFormsState();
}

class _PayGoogleFormsState extends State<PayGoogleForms> {
  WebViewController? _controller;
  String? paymentSessionUrl;

  String lang = "eng";
  List languages = [];

  double shippingFee = 10.0;
  List cartOrders = [];
  double totalPrices = 0.0;
  double finalTotalFinish = 0.0;

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

  Future<void> getInvoiceScreen() async {
    setState(() {
      _controller =
          WebViewController()
            ..loadRequest(
              Uri.parse(
                "https://docs.google.com/forms/d/e/1FAIpQLScD-ENv4QuUJINzjdf-nnDagWDdZ5EXtDlTjS4fRWXCpbOAZw/viewform?usp=pp_url&entry.1109870145=${widget.totalAmount}",
              ),
            )
            ..setNavigationDelegate(
              NavigationDelegate(
                onUrlChange: (change) async {
                  SharedPreferences prefx =
                      await SharedPreferences.getInstance();
                  print("URL Changed---> ${change.url}");
                  if (change.url!.contains("formResponse")) {
                    // هات البائعين الفريدين
                    final Set<dynamic> sellerUids =
                        cartOrders.map((order) => order['uid']).toSet();

                    // هات اسم العميل
                    print(
                      "SELECT Fullname FROM Users WHERE uid = '${prefx.getString("UID")}'",
                    );
                    var customerName = await AppUtils.makeRequests(
                      "fetch",
                      "SELECT Fullname FROM Users WHERE uid = '${prefx.getString("UID")}'",
                    );
                    if (customerName is Map<String, dynamic>) {
                      customerName = [customerName];
                    }
                    List results = [];
                    for (var sellerUid in sellerUids) {
                      // فلترة المنتجات الخاصة بالبائع ده فقط
                      final sellerProducts =
                          cartOrders
                              .where((e) => e['uid'] == sellerUid)
                              .toList();

                      // إضافة Order جديد للبائع
                      print(
                        "INSERT INTO Orders VALUES (NULL, '$sellerUid', '${prefx.getString("UID")}', '${prefx.getString("OID")}', '${Provider.of<AppProvider>(context, listen: false).shipId}', '${DateTime.now().toString()}', 'pending')",
                      );
                      await AppUtils.makeRequests(
                        "query",
                        "INSERT INTO Orders VALUES (NULL, '$sellerUid', '${prefx.getString("UID")}', '${prefx.getString("OID")}', '${Provider.of<AppProvider>(context, listen: false).shipId}', '${DateTime.now().toString()}', 'pending')",
                      );
                      // ابعت إشعار للبائع
                      results = await AppUtils.makeRequests(
                        "fetch",
                        "SELECT fcm_token FROM Users WHERE uid = '$sellerUid'",
                      );
                    }

                    if (results is Map<String, dynamic>) {
                      results = [results];
                    }
                    print("RESSSSS $results");
                    for (var result in results) {
                      print(result['fcm_token']);
                      PushNotificationServiceOrders.sendNotificationToUser(
                        result['fcm_token'],
                        "${languages[74][lang]} (${customerName[0]['Fullname']})",
                        "${languages[75][lang]} ${languages[76][lang]}",
                        prefx.getString("OID").toString(),
                        Provider.of<AppProvider>(context, listen: false).shipId,
                      );
                    }

                    var requestEmp = await AppUtils.makeRequests(
                      "fetch",
                      "SELECT * FROM employees",
                    );
                    for (var reqx in requestEmp) {
                      print(reqx['fcm_token']);
                      PushNotificationServiceOrders.sendNotificationToUser(
                        reqx['fcm_token'].toString(),
                        "${languages[74][lang]} (${customerName[0]['Fullname']})",
                        "${languages[75][lang]} ${languages[76][lang]}",
                        prefx.getString("OID").toString(),
                        Provider.of<AppProvider>(context, listen: false).shipId,
                      );
                    }

                    await AppUtils.makeRequests(
                      "query",
                      "INSERT INTO Notifications VALUES(NULL, '${languages[74][lang]} (${customerName[0]['Fullname']})', '${languages[75][lang]} ${languages[76][lang]}', '${DateTime.now().toString().split(' ')[0]}', 'false')",
                    );
                    if (Platform.isIOS) {
                      if (await canLaunchUrl(
                        Uri.parse(
                          "https://apps.apple.com/cy/app/ipay-qatar/id1581998579",
                        ),
                      )) {
                        await launchUrl(
                          Uri.parse(
                            "https://apps.apple.com/cy/app/ipay-qatar/id1581998579",
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } else {
                      if (await canLaunchUrl(
                        Uri.parse(
                          "https://play.google.com/store/apps/details?id=com.mwallet.vfq",
                        ),
                      )) {
                        await launchUrl(
                          Uri.parse(
                            "https://play.google.com/store/apps/details?id=com.mwallet.vfq",
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                    if (mounted) {
                      context.go('/paymentSuccess');
                    }
                  }
                },
              ),
            )
            ..setJavaScriptMode(JavaScriptMode.unrestricted);
    });
  }

  @override
  void initState() {
    super.initState();
    getLang();
    getCartOrders();
    getInvoiceScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WebViewWidget(controller: _controller!),
    );
  }
}
