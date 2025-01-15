// membership_details.dart
import 'package:flutter/material.dart';
import 'package:mymemberlink/model/membership.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/views/payment/billscreen.dart';
import 'package:mymemberlink/myconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MembershipDetails extends StatefulWidget {
  final User user;
  final Membership membership;

  const MembershipDetails({super.key, required this.user, required this.membership});

  @override
  State<MembershipDetails> createState() => _MembershipDetailsState();
}

class _MembershipDetailsState extends State<MembershipDetails> {
  bool isLoading = false;
  List<Map<String, dynamic>> purchaseHistory = [];
  @override
  Widget build(BuildContext context) {
    List<String> descriptionList = widget.membership.membershipDescription?.split(', ') ?? [];
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "${widget.membership.membershipName ?? "Membership Details"} Plan",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 10.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.membership.membershipName ?? "",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            for (String description in descriptionList)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.attach_money, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Price: ${getPrice(double.parse(widget.membership.membershipPrice.toString()))}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                int.parse(widget.membership.membershipDuration.toString()) == 1 
                ? const Text(' /month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(225, 76, 175, 79))) 
                : const Text(' /year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(225, 76, 175, 79))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _processMembershipPayment(widget.membership);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[800],
                ),
                child: const Text(
                  "Purchase",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPrice(double price) {
    String newPrice = 'RM${price.toStringAsFixed(2)}';
    return newPrice;
  }

  void _processMembershipPayment(Membership membership) async {
    try {
      double? price = double.tryParse(membership.membershipPrice ?? '0');
      if (price == null || price <= 0) {
        throw Exception('Invalid membership price');
      }

      // Create pending purchase first
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/mymemberlink/api/insert_pending_payment.php"),
        body: {
          'user_id': widget.user.userId.toString(),
          'membership_id': membership.membershipId.toString(),
          'amount': price.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          // Get the purchase_id and receipt_id from response
          final purchaseId = jsonResponse['data']['purchase_id'];
          final receiptId = jsonResponse['data']['receipt_id'];

          // Navigate to BillScreen with purchase details
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (content) => BillScreen(
                user: widget.user,
                totalprice: price,
                membership: membership,
                purchaseId: purchaseId.toString(),
                receiptId: receiptId,
              ),
            ),
          ).then((value) {
            Navigator.pop(context);
            Navigator.pop(context);
          });

          // Refresh the purchase history after returning
          _loadPurchaseHistory();
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Failed to create pending purchase');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadPurchaseHistory() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${MyConfig.servername}/mymemberlink/api/load_purchase_history.php?userid=${widget.user.userId}",
        ),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            purchaseHistory = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    }
    setState(() => isLoading = false);
  }
}