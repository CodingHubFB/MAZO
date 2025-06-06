import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mazo/Core/Utils.dart';
import 'package:mazo/provider/App_Provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoiceWebView extends StatefulWidget {
  final String orderId;
  final String? payment;
  final String? shipId;
  final String? custId;
  const InvoiceWebView({
    super.key,
    required this.orderId,
    this.payment,
    this.shipId,
    this.custId,
  });

  @override
  State<InvoiceWebView> createState() => _InvoiceWebViewState();
}

class _InvoiceWebViewState extends State<InvoiceWebView> {
  WebViewController? _controller;
  String? paymentSessionUrl;

  Future<void> getInvoiceScreen() async {
    SharedPreferences prefx = await SharedPreferences.getInstance();
    setState(() {
      _controller =
          WebViewController()
            ..loadRequest(
              Uri.parse(
                "https://pos7d.site/MAZO/Mazo_Invoice.php?uid=${widget.payment == 'Customer' ? '' : prefx.getString("UID")}&oid=${widget.orderId}&shipId=${widget.shipId != "" ? widget.shipId : Provider.of<AppProvider>(context, listen: false).shipId}&custId=${widget.custId}&k=${DateTime.now().millisecondsSinceEpoch}",
              ),
            )
            ..setJavaScriptMode(JavaScriptMode.unrestricted);
    });
  }

  // UID ---> 5440
  // OID ---> 7318

  @override
  void initState() {
    super.initState();
    getInvoiceScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            SharedPreferences prefx = await SharedPreferences.getInstance();
            if (widget.payment == "") {
              // AppUtils.sNavigateToReplace(context, '/customersOrders', {
              //   'custId': prefx.getString("UID")!,
              // });
              context.go('/customersOrders');
            } else {
              context.go('/paymentSuccess');
            }
          },
          icon: Icon(Iconsax.arrow_circle_left),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh), // أيقونة الريفريش
            onPressed: () {
              _controller?.reload(); // ريفريش للويب فيو
            },
          ),
        ],
        forceMaterialTransparency: true,
        centerTitle: true,
        title: const Text(
          "Your Invoice",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: WebViewWidget(controller: _controller!),
    );
  }
}
