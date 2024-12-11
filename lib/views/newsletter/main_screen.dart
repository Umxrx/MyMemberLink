import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/news.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/newsletter/edit_news.dart';
import 'package:mymemberlink/views/newsletter/new_news.dart';
//import 'package:mymemberlink/views/newsletter/new_news.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
  final ScrollController _listScrollController = ScrollController(keepScrollOffset: false);
  final df = DateFormat('[dd/MM/yyyy] hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;

  @override
  void initState() {
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        {
          if (didPop) {
            return;
          }
          final shouldPop = await _showBackDialog() ?? false;
          if (context.mounted && shouldPop == true) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text(style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), "My Member Link"),
            backgroundColor: Colors.blue[800],
            elevation: 10.0,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  //
                },
                icon: const ImageIcon(
                  AssetImage('assets/icon/user.png'),
                  size: 24,
                ),
              ),
            ],
          ),
          body: newsList.isEmpty
              ? const Center(
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10,),
                      Text(style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color.fromARGB(255, 65, 65, 65)), "LOADING..."),
                    ],
                  )),
                )
              : Column(
                  children: [
                    const SizedBox(height: 10,),
                    Container(
                      alignment: Alignment.center,
                      child: Text(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, wordSpacing: 5, color: Colors.grey[800]), "NEWSLETTER"),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]), "Page: $curpage/$numofpage | Result: $numofresult"),
                    ),
                    Expanded(
                      child: ListView.builder(
                          controller: _listScrollController,
                          itemCount: newsList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Card(
                                color: getColor(index),
                                elevation: 10,
                                child: ListTile(
                                  onLongPress: () {
                                    deleteDialog(index);
                                  },
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        newsList[index].newsTitle.toString(),
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 2,),
                                      Text(
                                        df.format(DateTime.parse(
                                          newsList[index].newsDate.toString())),
                                        style: const TextStyle(fontSize: 10, color: Colors.white54),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2,),
                                    ],
                                  ),
                                  subtitle: Text(
                                    newsList[index].newsDetails.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                  ),
                              
                                  // leading: const Icon(Icons.article),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      showNewsDetailsDialog(index);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          //build the list for textbutton with scroll
                          if ((curpage - 1) == index) {
                            //set current page number active
                            color = Colors.blue;
                          } else {
                            color = Colors.black;
                          }
                          return TextButton(
                              onPressed: () {
                                curpage = index + 1;
                                loadNewsData();
                              },
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
          drawer: const MyDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (content) => const NewNewsScreen()));
              loadNewsData();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 10,
            tooltip: "Add News",
            shape: RoundedRectangleBorder(side: const BorderSide(width: 2, color: Colors.white, strokeAlign: 1.0), borderRadius: BorderRadius.circular(100)),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
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

  void loadNewsData() {
    http.get(Uri.parse("${MyConfig.servername}/memberlink/api/load_news.php?pageno=$curpage"))
    .then((response) {
      // log(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();
          for (var item in result) {
            News news = News.fromJson(item);
            newsList.add(news);
          }
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
          log('Number of page   : $numofpage');
          log('Number of result : $numofresult');
          setState(() {});
        }
      } else {
        log('Error loading data');
      }
    });
    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  void showNewsDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(newsList[index].newsTitle.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
            backgroundColor: getColor(index),
            content: Text(truncateString(newsList[index].newsDetails.toString(), 300),
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.white70),
                ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  News news = newsList[index];

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => EditNewsScreen(news: news)));
                  loadNewsData();
                },
                child: const Text("Edit", style: TextStyle(color: Colors.white),),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white))
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
              "Delete \"${newsList[index].newsTitle.toString()}\"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: getColor(index),
            content: const Text("Are you sure you want to delete this news?", style: TextStyle(color: Colors.white70),),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteNews(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete", style: TextStyle(color: Colors.red),)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white),))
            ],
          );
        });
  }

  void deleteNews(int index) {
    http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/delete_news.php"),
        body: {"newsid": newsList[index].newsId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("The news has been deleted successfully"),
            backgroundColor: Colors.green,
          ));
          loadNewsData(); //reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something went wrong..."),
            backgroundColor: Colors.red,
          ));
        }
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
  
  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Exit?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          content: const Text(
            'You will be automatically logged out if you leave now. Are you sure you want to exit?',
            textAlign: TextAlign.justify,
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                //Navigator.pop(context, true);
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white
              ),
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }
}