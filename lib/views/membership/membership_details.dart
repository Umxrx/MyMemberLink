// membership_details.dart
import 'package:flutter/material.dart';
import 'package:mymemberlink/model/membership.dart';
import 'package:mymemberlink/model/user.dart';

class MembershipDetails extends StatelessWidget {
  final User user;
  final Membership membership;

  const MembershipDetails({super.key, required this.user, required this.membership});

  @override
  Widget build(BuildContext context) {
    List<String> descriptionList = membership.membershipDescription?.split(', ') ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          membership.membershipName ?? "Membership Details",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              membership.membershipName ?? "",
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
                  "Price: ${getPrice(double.parse(membership.membershipPrice.toString()))}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                int.parse(membership.membershipDuration.toString()) == 1 
                ? const Text(' /month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(225, 76, 175, 79))) 
                : const Text(' /year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(225, 76, 175, 79))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Purchase logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase button pressed.')),
                  );
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
}