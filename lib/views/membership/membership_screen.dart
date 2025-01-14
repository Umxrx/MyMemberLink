import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymemberlink/model/membership.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';

class MembershipScreen extends StatefulWidget {
  final User user;
  const MembershipScreen({super.key, required this.user});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  List<Membership> membershipList = []; 
  late double screenWidth, screenHeight;
  String status = 'LOADING...';
  final df = DateFormat('[dd/MM/yyyy] hh:mm a');

  @override
  void initState() {
    super.initState();
    loadMembershipData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), "Membership Plan"),
        backgroundColor: Colors.blue[800],
        elevation: 10.0,
        foregroundColor: Colors.white,
      ),
      body: membershipList.isEmpty
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
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: membershipList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            color: getColor(index),
                            elevation: 10,
                            child: ListTile(
                              onTap: () {
                                // deleteDialog(index);
                                // Show details of the membership
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    membershipList[index].membershipName.toString(),
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2,),
                                ],
                              ),
                              subtitle: Text(
                                membershipList[index].membershipDescription.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              )

    );
  }
  
  void loadMembershipData() {
    http.get(Uri.parse("${MyConfig.servername}/memberlink/api/load_membership.php"))
    .then((response) {
      // log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['membership'];
          membershipList.clear();
          for (var item in result) {
            Membership membership = Membership.fromJson(item);
            membershipList.add(membership);
          }
          setState(() {
            status = 'LOADING...';
          });
        }
        else {
          log('No available data');
          setState(() {
            status = 'NO AVAILABLE DATA';
          });
        }
      } else {
        log('Error loading data');
        setState(() {
          status = 'ERROR';
        });
      }
    });
  }

  Color? getColor(int index) {
    Color? colorResult;
    if (index == 0) {
      colorResult = Colors.blue;
    }
    else if (index == 1) {
      colorResult = const Color.fromARGB(255, 31, 136, 223);
    }
    else if (index == 2) {
      colorResult = const Color.fromARGB(255, 28, 123, 201);
    }
    else if (index == 3) {
      colorResult = const Color.fromARGB(255, 24, 108, 177);
    }
    else if (index == 4) {
      colorResult = const Color.fromARGB(255, 21, 96, 156);
    }
    else if (index == 5) {
      colorResult = const Color.fromARGB(255, 19, 83, 136);
    }
    else if (index == 6) {
      colorResult = const Color.fromARGB(255, 17, 73, 119);
    }
    else if (index == 7) {
      colorResult = const Color.fromARGB(255, 16, 65, 105);
    }
    else if (index == 8) {
      colorResult = const Color.fromARGB(255, 14, 57, 92);
    }
    else {
      colorResult = const Color.fromARGB(255, 12, 49, 80);
    }
    return colorResult;
  }
}

// MEMBERSHIP PLANS
/*
1. Economic (RM10.00/month)
      - No Ads
      - 10 GB Cloud Space Storage
      - 1 User Account
      - 1 Device Access

2. Basic (RM28.00/month)
      - No Ads
      - 300 GB Cloud Space Storage
      - 3 User Account
      - 3 Device Access

3. Pro (RM42.00/month)
      - No Ads
      - 500 GB Cloud Space Storage
      - 10 User Account
      - 10 Device Access

4. Business (RM89.00/month)
      - No Ads
      - Unlimited Cloud Space Storage
      - 20 User Account
      - 20 Device Access
*/