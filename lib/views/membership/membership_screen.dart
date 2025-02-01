import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mymemberlink/model/membership.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/views/membership/membership_details.dart';
import 'package:mymemberlink/views/payment/payment_history_screen.dart';

class MembershipScreen extends StatefulWidget {
  final User user;
  const MembershipScreen({super.key, required this.user});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  List<Membership> membershipList = [];
  final df = DateFormat('[dd/MM/yyyy] hh:mm a');
  bool userHasMembership = false;
  String userMembershipName = '';
  bool isLoading = false;
  late PageController _pageController;
  List<Map<String, dynamic>> purchaseHistory = [];
  // Adjust this fraction to control how much neighboring cards are visible.
  final double _viewportFraction = 0.6;

  double screenWidth = 0, screenHeight = 0;
  String status = 'LOADING...';

  final String subscriptionText = 
      "After you confirm your purchase, your Google Play account will be charged "
      "for the initial subscription period fee. Your subscription will be "
      "automatically renewed unless you turn off auto-renewal at least 24 hours "
      "before the end of your current subscription period. Your subscription will "
      "be renewed for the same period as your initial selection. You will receive "
      "notice of renewal at least 24 hours (unless otherwise mandated by laws or "
      "regulations) before renewal through in-app notification, email, or other "
      "effective alternative methods which will state the renewal amount. Your "
      "account will be charged for renewal within the last 24 hours before the end "
      "of your current subscription period. You can turn off auto-renewal in the "
      "account settings of Google at any time.";

  @override
  void initState() {
    super.initState();
    loadMembershipData();
    loadUserMembership();
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Membership Plan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentHistoryScreen(user: widget.user))).then((onValue) {
                loadMembershipData();
                loadUserMembership();
              });
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
        elevation: 10.0,
      ),
      body: membershipList.isEmpty
          ? _buildEmptyState()
          : _buildBody(),
    );
  }

  /// A scrollable layout that shows the membership cards at the top
  /// (with limited height) and the long subscription text below.
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // A box that takes ~40% of the screen height (adjust as needed)
          SizedBox(
            height: screenHeight * 0.4,
            child: _buildMembershipCards(),
          ),
          // Some spacing
          const SizedBox(height: 30),
          // The long subscription text in a padded container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Subscription Terms",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.info_outline, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  subscriptionText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (status.contains('LOADING...'))
            const CircularProgressIndicator()
          else
            Column(
              children: [
                SizedBox(
                  height: screenHeight / 5,
                  child: Image.asset('assets/icon/error_notfound.png'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            status,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color.fromARGB(255, 65, 65, 65),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal PageView of membership cards
  Widget _buildMembershipCards() {
    return PageView.builder(
      controller: _pageController,
      itemCount: membershipList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        // Animate scale based on how close this page is to the center
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.hasClients && _pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              // A value of 0.0 for centered card, -1.0 or 1.0 for neighbors, etc.
              value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
            }
            // Scale transform for that "bigger in center" effect
            return Center(
              child: SizedBox(
                width: screenWidth * 0.7,
                child: Transform.scale(
                  scale: value,
                  child: _buildCard(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Card UI for each membership plan
  Widget _buildCard(int index) {
    final membership = membershipList[index];
    String descriptions = membership.membershipDescription ?? "";
    List<String> descriptionList = descriptions.split(', ');
    int cardColor = hasColor(userMembershipName);
    log('Card Color: $cardColor');
    log('Index: ${index + 1}');
    return Card(
      color: cardColor >= index + 1
        ? Colors.grey
        : getColor(index),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          cardColor >= index + 1
          ? membershipExistedDialog()
          : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MembershipDetails(user: widget.user, membership: membership)),
          ).then((onValue) {
            loadMembershipData();
            loadUserMembership();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                membership.membershipName ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              for (MapEntry<int, String> entry in descriptionList.asMap().entries)
                Column(
                  children: [
                    entry.key != 0 ? const SizedBox(height: 8) : const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: Text(
                            entry.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getPrice(double.parse(membership.membershipPrice.toString())),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 189, 90),
                    ),
                  ),
                  int.parse(membership.membershipDuration.toString()) == 1 
                  ? const Text(' /month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(190, 255, 153, 0)))
                  : const Text(' /year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(190, 255, 153, 0))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Load membership data from API
  void loadMembershipData() async {
    try {
      final response = await http
          .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_membership.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          final result = data['data']['membership'];
          membershipList.clear();
          for (var item in result) {
            membershipList.add(Membership.fromJson(item));
          }
          if (mounted) {
            setState(() {
              status = 'Data Loaded';
            });
          }
        } else {
          log('No available data');
          if (mounted) {
            setState(() {
              status = 'NO AVAILABLE DATA';
            });
          }
        }
      } else {
        log('Error loading data');
        if (mounted) {
          setState(() {
            status = 'ERROR';
          });
        }
      }
    } catch (e) {
      log('Exception: $e');
      if (mounted) {
        setState(() {
          status = 'ERROR';
        });
      }
    }
  }

  /// Unique color per card index
  Color getColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return const Color.fromARGB(255, 31, 136, 223);
      case 2:
        return const Color.fromARGB(255, 28, 123, 201);
      case 3:
        return const Color.fromARGB(255, 24, 108, 177);
      case 4:
        return const Color.fromARGB(255, 21, 96, 156);
      case 5:
        return const Color.fromARGB(255, 19, 83, 136);
      case 6:
        return const Color.fromARGB(255, 17, 73, 119);
      case 7:
        return const Color.fromARGB(255, 16, 65, 105);
      case 8:
        return const Color.fromARGB(255, 14, 57, 92);
      default:
        return const Color.fromARGB(255, 12, 49, 80);
    }
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

  void loadUserMembership() async {
    final (boole, namee) = await hasMembership();

    if (mounted) {
      setState(() {
        userHasMembership = boole;
        userMembershipName = namee;
      });
    }
  }

  int hasColor(String memberName) {
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
}
