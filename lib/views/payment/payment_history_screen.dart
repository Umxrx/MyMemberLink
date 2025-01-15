import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    loadPurchaseHistory();
  }

  Future<void> loadPurchaseHistory() async {
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
        } else {
          setState(() {
            purchaseHistory = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.pending;
        break;
      case 'failed':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          purchase['membership_name'] ?? 'Unknown Membership',
          style: const TextStyle(
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
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(
                    DateTime.parse(purchase['purchase_date']),
                  ),
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
                  'RM ${purchase['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
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
                    backgroundColor: const Color(0xFF463F3A),
                  ),
                  onPressed: () => _continuePurchase(purchase),
                  child: const Text(
                    'Continue Purchase',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showReceiptDialog(purchase),
      ),
    );
  }

  void _continuePurchase(Map<String, dynamic> purchase) async {
    try {
      // Get membership details
      final response = await http.get(
        Uri.parse(
          "${MyConfig.servername}/mymemberlink/api/get_membership.php?membership_id=${purchase['membership_id']}",
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final membership = Membership.fromJson(jsonResponse['data']);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (content) => BillScreen(
                  user: widget.user,
                  totalprice: double.parse(purchase['amount'].toString()),
                  membership: membership,
                  purchaseId: purchase['purchase_id'],
                  receiptId: purchase['receipt_id'],
                ),
              ),
            ).then((_) => loadPurchaseHistory());
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error continuing purchase: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment History",
          style: GoogleFonts.monoton(color: const Color(0xFFF4F3EE)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF463F3A),
        iconTheme: const IconThemeData(color: Color(0xFFF4F3EE)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
            'MyMemberLink',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            '123 Business Street\nCity, State 12345',
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
}