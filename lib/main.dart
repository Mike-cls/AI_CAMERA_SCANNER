import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Camera Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'AI Camera Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Result {
  String ContentType;
  String Content;
  String Format;
  DateTime age;

  //Result(this.ContentType, this.Content, this.Format, this.age);

  Result(this.ContentType, this.Content, this.Format, String date) {
    age = DateTime.parse(date);
  }

  factory Result.fromJson(dynamic json) {
    return Result(json['ContentType'] as String, json['Content'] as String,
        json['Format'] as String, json['age'] as String);
  }

  @override
  String toString() {
    return '{"ContentType":"${this.ContentType}", "Content":"${this.Content}", "Format":"${this.Format}", "age":"${this.age}"}';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<Result> _entries = new List<Result>();
  final List<String> MenuChoices = <String>['Clear all history'];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _MyHomePageState() {
    getEntries();
  }

  Future getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String results = prefs.getString("result");
      print("GET: " + results);

      if (results != null && results.isNotEmpty) {
        var x = json.decode(results)["results"] as List;
        _entries = x.map((tagJson) => Result.fromJson(tagJson)).toList();
        _entries.sort((a, b) => a.age.compareTo(b.age) == 0 ? -1 : 0);
        print("Count: " + _entries.length.toString());
      }
    } catch (Exception) {
      print("Error: " + Exception.toString());
      _entries.clear();
      prefs.setString("result", "");
    }
  }

  Future insertEntries(
      String ContentType, String Content, String Format) async {
    _entries.insert(
        0, new Result(ContentType, Content, Format, DateTime.now().toString()));
    final prefs = await SharedPreferences.getInstance();
    String result = '{"results":[';
    for (int i = 0; i < _entries.length; i++) {
      result += _entries[i].toString() + ",";
    }
    if (result != '{"results":[') {
      result = result.substring(0, result.length - 1) + "]}";
      print("SAVE: " + result);
      prefs.setString("result", result);
    }
    //String result = json.encode(_entries).toString();
    //print("SAVE: " + result);
    //prefs.setString("result", result);
  }

  void selectedChoice(String choice) async {
    if (choice == 'Clear all history') {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("result", "");
      _entries.clear();
      setState(() {
        getEntries();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: selectedChoice,
            itemBuilder: (BuildContext Context) {
              return MenuChoices.map((String choice) {
                return PopupMenuItem<String>(
                    value: choice, child: Text(choice));
              }).toList();
            },
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        itemCount: _entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
              color: Colors.green,
              child: InkWell(
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: _entries[index].Content));
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(_entries[index].Content + ' copied to clipboard.'),
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      color: Colors.amber[index > 0 ? 100 : 500],
                      child: Column(children: [
                        Row(
                          children: [
                            Text(
                              "Scan Date: ",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _entries[index].age.toString().substring(0, 19),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        /*Row(
                          children: [
                            Text(
                              "Type: ",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _entries[index].ContentType,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),*/
                        Row(children: [
                          Text(
                            "Value: ",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _entries[index].Content,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ]),
                        Row(children: [
                          Text(
                            "Format: ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _entries[index].Format,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          )
                        ])
                      ])
                      //Center(child: Text('Entry ${entries[index]}')),
                      )));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var options = ScanOptions(

          );
          var result = await BarcodeScanner.scan();
          if (result.type == ResultType.Barcode)
            setState(() {
              insertEntries(
                  result.type.toString(),
                  result.rawContent.toString(),
                  result.format.toString() == 'unknown'
                      ? result.formatNote.toUpperCase()
                      : result.format.toString().toUpperCase());
              getEntries();
            });

          print(result.type); // The result type (barcode, cancelled, failed)
          print(result.rawContent); // The barcode content
          print(result.format); // The barcode format (as enum)
          print(result
              .formatNote); // If a unknown format was scanned this field contains a note

          // final SharedPreferences prefs = await _prefs;
        },
        tooltip: 'Scan Barcode',
        child: Icon(Icons.photo_camera),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
