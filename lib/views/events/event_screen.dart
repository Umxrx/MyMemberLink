import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/myevent.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/events/new_event.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<MyEvent> eventsList = [];
  late double screenWidth, screenHeight;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String status = "Loading...";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadEventsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {}
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
        ],
      ),
      body: eventsList.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            )
          : GridView.count(
              childAspectRatio: 0.8,
              crossAxisCount: 2,
              children: List.generate(eventsList.length, (index) {
                return Card(
                  child: InkWell(
                    splashColor: Colors.red,
                    onLongPress: () {},
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                      child: Column(children: [
                        Text(
                          eventsList[index].eventTitle.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          child: Image.network(
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    "assets/images/na.png",
                                  ),
                              width: screenWidth / 2,
                              height: screenHeight / 6,
                              fit: BoxFit.cover,
                              scale: 4,
                              "${MyConfig.servername}/memberlink/assets/events/${eventsList[index].eventFilename}"),
                        ),
                        Text(eventsList[index].eventType.toString()),
                        Text(df.format(DateTime.parse(
                            eventsList[index].eventDate.toString()))),
                      ]),
                    ),
                  ),
                );
              })),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (content) => const NewEventScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void loadEventsData() {
    http
        .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_events.php"))
        .then((response) {
      log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['events'];
          eventsList.clear();
          for (var item in result) {
            MyEvent myevent = MyEvent.fromJson(item);
            eventsList.add(myevent);
          }
          setState(() {});
        } else {
          status = "No Data";
        }
      } else {
        status = "Error loading data";
        print("Error");
        setState(() {});
      }
    });
  }
}