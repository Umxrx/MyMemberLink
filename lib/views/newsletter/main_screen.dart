import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/model/news.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/shared/mydrawer.dart';
import 'package:mymemberlink/views/newsletter/edit_news.dart';
//import 'package:mymemberlink/views/newsletter/new_news.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
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
    return Scaffold(
        appBar: AppBar(
          title: const Text(style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), "My Member Link"),
          backgroundColor: Colors.blue[800],
          elevation: 10.0,
          foregroundColor: Colors.white,
        ),
        body: newsList.isEmpty
            ? const Center(
                child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10,),
                    Text(style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color.fromARGB(255, 65, 65, 65)), "LOADING..."),
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
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          int col = colorIndex(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              color: Colors.blue[col],
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
                                      df.format(DateTime.parse(newsList[index].newsDate.toString())),
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
        /* floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // loadNewsData();
                MaterialPageRoute(builder: (content) => const NewNewsScreen());
            loadNewsData();
          },
          child: const Icon(Icons.add),
        ) */
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
    http.get(Uri.parse("${MyConfig.servername}/memberlink/api/load_news.php?pageno=$curpage")).then((response) {
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
          print(numofpage);
          print(numofresult);
          setState(() {});
        }
      } else {
        print("Error");
      }
    });
  }

  void showNewsDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(newsList[index].newsTitle.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
            backgroundColor: Colors.blue[colorIndex(index)],
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
              "Delete \"${truncateString(newsList[index].newsTitle.toString(), 20)}\"",
              style: const TextStyle(fontSize: 18),
            ),
            content: const Text("Are you sure you want to delete this news?"),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteNews(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"))
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

  int colorIndex(int index) {
    int indexResult;
    if (index == 0 || index == 5) {
      indexResult = 500;
    }
    else if (index == 1 || index == 6) {
      indexResult = 600;
    }
    else if (index == 2 || index == 7) {
      indexResult = 700;
    }
    else if (index == 3 || index == 8) {
      indexResult = 800;
    }
    else {
      indexResult = 900;
    }
    return indexResult;
  }
}