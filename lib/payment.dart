import 'dart:async';
import 'package:my_pickup/user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final User user;
  final String orderid, val;
  PaymentPage({this.user, this.orderid, this.val});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Payment'),
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: WebView(
                    initialUrl:
                        'http://pickupandlaundry.com/my_pickup/gifhary/payment.php?email=' +
                            widget.user.email +
                            '&mobile=' +
                            widget.user.phone +
                            '&name=' +
                            widget.user.name +
                            '&amount=' +
                            widget.val +
                            '&orderid=' +
                            widget.orderid,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                  ),
                )
              ],
            )));
  }

  Future<bool> _onBackPressAppBar() async {
   Navigator.pop(context, "payment");
    return Future.value(false);
  }
}
