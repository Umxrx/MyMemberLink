import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/model/membership.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:google_fonts/google_fonts.dart';

class BillScreen extends StatefulWidget {
  final User user;
  final double totalprice;
  final Membership membership;
  final String purchaseId;
  final String receiptId;

  const BillScreen({
    super.key,
    required this.user,
    required this.totalprice,
    required this.membership,
    required this.purchaseId,
    required this.receiptId,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  WebViewController controller = WebViewController();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WebViewPlatform.instance = AndroidWebViewPlatform();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
            debugPrint('Loading URL: $url');
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
            debugPrint('Finished loading URL: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              hasError = true;
              errorMessage = error.description;
              isLoading = false;
            });
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse("${MyConfig.servername}/mymemberlink/api/payment.php?"
            "userid=${widget.user.userId}"
            "&email=${Uri.encodeComponent(widget.user.userEmail ?? '')}"
            "&phone=${Uri.encodeComponent(widget.user.userPhone ?? '')}"
            "&name=${Uri.encodeComponent(widget.user.userName ?? '')}"
            "&amount=${widget.totalprice}"
            "&type=membership"
            "&membershipId=${widget.membership.membershipId}"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Payment",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF4F3EE),
            ),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: const Color(0xFF463F3A),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFF4F3EE),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
        ),
        body: Stack(
          children: [
            if (!hasError) WebViewWidget(controller: controller),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load payment page\n$errorMessage'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                        });
                        controller.reload();
                      },
                      child: const Text('Retry'),
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
