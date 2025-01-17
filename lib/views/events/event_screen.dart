import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/myevent.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/events/edit_event.dart';
import 'package:mymemberlink/views/events/new_event.dart';

class EventScreen extends StatefulWidget {
  final User user;
  const EventScreen({super.key, required this.user});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<MyEvent> eventsList = [];
  late double screenWidth, screenHeight;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String status = "LOADING...";
  @override
  void initState() {
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
        title: const Text("Events",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {
            //
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: eventsList.isEmpty
          ? Center(
              child: Column(
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
                  Text(
                    status,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 65, 65, 65),
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : GridView.count(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              children: List.generate(eventsList.length, (index) {
                return Card(
                  child: InkWell(
                    splashColor: Colors.red,
                    onLongPress: () {
                      deleteDialog(index);
                    },
                    onTap: () {
                      showEventDetailsDialog(index);
                    },
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
                                  SizedBox(
                                    height: screenHeight/6,
                                    child: Image.asset(
                                      "assets/icon/error_notfound.png",
                                    ),
                                  ),
                              width: screenWidth / 2,
                              height: screenHeight / 6,
                              fit: BoxFit.cover,
                              scale: 4,
                              "${MyConfig.servername}/memberlink/assets/events/${eventsList[index].eventFilename}"),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            eventsList[index].eventType.toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(df.format(DateTime.parse(
                            eventsList[index].eventDate.toString()))),
                        Text(truncateString(
                            eventsList[index].eventDescription.toString(), 45)),
                      ]),
                    ),
                  ),
                );
              })),
      drawer: MyDrawer(
        user: widget.user,
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (content) => const NewEventScreen()));
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 10,
            tooltip: "Add Event",
            shape: RoundedRectangleBorder(side: const BorderSide(width: 2, color: Colors.white, strokeAlign: 1.0), borderRadius: BorderRadius.circular(100)),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
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
          log('No data');
          setState(() {
            status = "NO AVAILABLE DATA";
          });
        }
      } else {
        status = "ERROR";
        log("Error");
        setState(() {});
      }
    });
  }

  void showEventDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(eventsList[index].eventTitle.toString()),
            content: SingleChildScrollView(
              child: Column(children: [
                Image.network(
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                          "assets/icon/error_notfound.png",
                        ),
                    width: screenWidth,
                    height: screenHeight / 4,
                    fit: BoxFit.cover,
                    scale: 4,
                    "${MyConfig.servername}/memberlink/assets/events/${eventsList[index].eventFilename}"),
                Text(eventsList[index].eventType.toString()),
                Text(df.format(
                    DateTime.parse(eventsList[index].eventDate.toString()))),
                Text(eventsList[index].eventLocation.toString()),
                const SizedBox(height: 10),
                Text(
                  eventsList[index].eventDescription.toString(),
                  textAlign: TextAlign.justify,
                )
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  MyEvent myevent = eventsList[index];
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => EditEventScreen(
                                myevent: myevent,
                              )));
                  loadEventsData();
                },
                child: const Text("Edit Event"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              )
            ],
          );
        });
  }

  void deleteDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                "Delete \"${truncateString(eventsList[index].eventTitle.toString(), 20)}\"",
                style: const TextStyle(fontSize: 18),
              ),
              content:
                  const Text("Are you sure you want to delete this event?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    deleteNews(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                )
              ]);
        });
  }

  void deleteNews(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/delete_event.php"),
        body: {
          "eventid": eventsList[index].eventId.toString()
        }).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
          loadEventsData(); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}