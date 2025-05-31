import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class TapPaymentWebView extends StatefulWidget {
  const TapPaymentWebView({super.key});

  @override
  State<TapPaymentWebView> createState() => _TapPaymentWebViewState();
}

class _TapPaymentWebViewState extends State<TapPaymentWebView> {
  WebViewController? _controller;
  String? paymentSessionUrl;

  Future<void> createPaymentSession() async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://pos7d.site/MAZO/create_tap_charge.php',
        data: {
          "amount": 1000,
          "currency": "KWD",
          "customer": {"email": "test@example.com", "name": "Test User"},
          "billing": {
            "address": {"country": "KW"},
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      dynamic data = response.data;

      // تأكد إننا حولنا البيانات من String لو كانت كده
      if (data is String) {
        data = json.decode(data);
      }

      final paymentSessionLink = data['payment_url'];

      if (paymentSessionLink == null) {
        throw Exception('Payment session link not found in response');
      }

      print('✅ Payment URL: $paymentSessionLink');

      setState(() {
        paymentSessionUrl = paymentSessionLink;
        _controller =
            WebViewController()
              ..loadRequest(Uri.parse(paymentSessionUrl!))
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (request) {
                    if (request.url.contains('Success.php')) {
                      context.go('/success');
                      return NavigationDecision.prevent;
                    } else if (request.url.contains('Failed.php')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment failed or canceled'),
                        ),
                      );
                      context.pop();
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              );
      });
    } catch (e) {
      print('❌ Error creating payment session: $e');
      if (e is DioException) {
        print('🔴 Response: ${e.response?.data}');
        print('🔴 Status code: ${e.response?.statusCode}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create payment session')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    createPaymentSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: const Text(
          "Processing Payment",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
      ),
      body:
          paymentSessionUrl == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _controller!),
    );
  }
}
