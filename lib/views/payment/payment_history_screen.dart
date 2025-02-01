import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/views/payment/billscreen.dart';
import 'package:mymemberlink/model/membership.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final User user;
  const PaymentHistoryScreen({super.key, required this.user});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>> purchaseHistory = [];
  bool isLoading = true;
  String status = 'LOADING...';
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    loadPurchaseHistory();
  }

  Future<void> loadPurchaseHistory() async {
    setState(() {
      isLoading = true;
      status = 'LOADING...';
    });
    Future.delayed(const Duration(seconds: 2));
    try {
      final response = await http.get(
        Uri.parse(
          "${MyConfig.servername}/memberlink/api/load_purchase_history.php?userid=${widget.user.userId}",
        ),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            purchaseHistory = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
            status = 'LOADING...';
          });
        } else {
          setState(() {
            purchaseHistory = [];
            isLoading = false;
            status = 'NO AVAILABLE DATA';
          });
        }
      } else {
        setState(() {
          purchaseHistory = [];
          isLoading = true;
          status = 'ERROR';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = true;
          status = 'ERROR';
        });
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.white;
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.white;
        textColor = Colors.orange;
        icon = Icons.pending;
        break;
      case 'failed':
        backgroundColor = Colors.white;
        textColor = Colors.red;
        icon = Icons.error;
        break;
      default:
        backgroundColor = Colors.white;
        textColor = Colors.grey.shade900;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    return Card(
      color: Colors.blue,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          purchase['membership_name'] ?? 'Unknown Membership',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.white,),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.parse(purchase['purchase_date']),),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            if (purchase['expiry_date'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Expires: ${DateFormat('dd MMM yyyy').format(
                      DateTime.parse(purchase['expiry_date']),
                    )}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getPrice(purchase['amount'].toDouble()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(purchase['payment_status']),
              ],
            ),
            if (purchase['payment_status'].toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () => _continuePurchase(purchase, purchase['membership_name']),
                  child: const Text(
                    'Make Purchase',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showReceiptDialog(purchase),
      ),
    );
  }

  void _continuePurchase(Map<String, dynamic> purchase, String membershipName) async {
    final (userHasMembership, userMembershipName) = await hasMembership();
    int memberRank = membershipIds(userMembershipName);
    int chosenRank = membershipIds(membershipName);
    if (!userHasMembership || (userHasMembership && chosenRank > memberRank)) {
      try {
        List<Membership> memberlist = [];
        await http
            .get(Uri.parse("${MyConfig.servername}/memberlink/api/one_membership.php?membership_name=$membershipName"))
            .then((value) {
              if (value.statusCode == 200) {
                final data = jsonDecode(value.body);
                log('Response Data: $data');
                if (data['status'] == "success") {
                  final result = data['data']['membership'];
                  log('Result: $result');
                  for (var item in result) {
                    log('Trying to loop...');
                    memberlist.add(Membership.fromJson(item));
                  }
                  if (mounted) {
                    log('Purchase Content: $purchase');
                    Membership pushedMembership = memberlist.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (content) => BillScreen(
                          user: widget.user,
                          totalprice: double.parse(purchase['amount']?.toString() ?? '0.0'),
                          membership: pushedMembership,
                          purchaseId: purchase['purchase_id'].toString(),
                          receiptId: purchase['receipt_id'],
                        ),
                      ),
                    ).then((_) {
                      Navigator.pop(context);
                      loadPurchaseHistory();
                      Navigator.pop(context);
                    });
                  }
                } else {
                  log('No available data');
                }
              } else {
                log('Error loading data');
              }
            });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error continuing purchase: $e')),
          );
          log('Error Message: $e');
        }
      }
    }
    else {
      //Pop up window says membership already exists
      membershipExistedDialog();
    }
  }

  int membershipIds(String memberName) {
    if (memberName == 'Economic') {
      return 1;
    }
    else if (memberName == 'Basic') {
      return 2;
    }
    else if (memberName == 'Pro') {
      return 3;
    }
    else if (memberName == 'Business') {
      return 4;
    }
    else {
      return 0;
    }
  }

  void membershipExistedDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Already a Member', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
            backgroundColor: Colors.blue,
            content: Text(truncateString('Your membership is currently active. You can renew your membership after it expires.', 300),
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.white70),
                ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Okay", style: TextStyle(color: Colors.white))
              )
            ],
          );
        });
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        title: const Text(
          "Payment History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  status.contains('LOADING...')
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      SizedBox(
                        height: screenHeight / 5,
                        child: Image.asset('assets/icon/error_notfound.png'),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Text(status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color.fromARGB(255, 65, 65, 65)),),
                ],
              )),
            )
          : RefreshIndicator(
              onRefresh: loadPurchaseHistory,
              child: purchaseHistory.isEmpty
                  ? const Center(
                      child: Text('No payment history available'),
                    )
                  : ListView.builder(
                      itemCount: purchaseHistory.length,
                      itemBuilder: (context, index) {
                        final purchase = purchaseHistory[index];
                        return _buildPurchaseCard(purchase);
                      },
                    ),
            ),
    );
  }

  void _showReceiptDialog(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Receipt Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF463F3A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECEIPT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Receipt Content
                _buildReceiptContent(payment),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptContent(Map<String, dynamic> payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 60),
          const SizedBox(height: 8),
          const Text(
            'My Member Link',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Universiti Utara Malaysia\nChanglun, Sintok, Kedah',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildDottedLine(),
          const SizedBox(height: 20),
          _buildReceiptRow('Name', widget.user.userName ?? 'N/A'),
          _buildReceiptRow('Email', widget.user.userEmail ?? 'N/A'),
          _buildReceiptRow('Phone', widget.user.userPhone ?? 'N/A'),
          const SizedBox(height: 20),
          _buildDottedLine(),
          const SizedBox(height: 20),
          _buildReceiptRow('Receipt ID', payment['receipt_id']),
          _buildReceiptRow(
            'Date',
            DateFormat('dd/MM/yyyy HH:mm').format(
              DateTime.parse(payment['purchase_date']),
            ),
          ),
          const SizedBox(height: 20),
          _buildDottedLine(),
          const SizedBox(height: 20),
          _buildReceiptRow(
            'Membership',
            payment['membership_name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (payment['expiry_date'] != null)
            _buildReceiptRow(
              'Valid Until',
              DateFormat('dd/MM/yyyy').format(
                DateTime.parse(payment['expiry_date']),
              ),
            ),
          const SizedBox(height: 20),
          _buildDottedLine(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'RM ${payment['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Thank you for your business!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'For support: help@mymemberlink.com',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedLine() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 2,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String getPrice(double price) {
    String newPrice = 'RM${price.toStringAsFixed(2)}';
    return newPrice;
  }

  Future<(bool, String)> hasMembership() async {
    try {
      // Get membership detail
      final response = await http.get(
        Uri.parse(
          "${MyConfig.servername}/memberlink/api/get_membership.php?userid=${widget.user.userId}",
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          String membership = jsonResponse['membership_name'];
          if (membership == 'No active membership') {
            return Future.value((false, ''));
          }
          else {
            return Future.value((true, membership));
          }
        }
        else {
          return Future.value((false, ''));
        }
      }
      else {
        return Future.value((false, ''));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching membership: $e')),
        );
      }
      return Future.value((false, ''));
    }
  }
}