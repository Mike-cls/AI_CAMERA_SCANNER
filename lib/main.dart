import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

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
      home: MyHomePage(title: 'Welcome to AI Camera Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _ContentType = "";
  String _Content = "";
  String _Format = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            children: [
                Text(
                  "Type: ",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                    "$_ContentType",
                    key: Key("ContentType"),
                    style: TextStyle(
                      fontSize: 18,
                  ),
                ),
              ],
            ),
          Row(
            children:[
              Text(
                "Content: ",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "$_Content",
                key: Key("Content"),
                style: TextStyle(
                  fontSize: 18,
                ),
              )
            ]
          ),
          Row(
              children:[
                Text(
                  "Format: ",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  "$_Format",
                  key: Key("Format"),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ]
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await BarcodeScanner.scan();

          setState(() {
            _ContentType = result.type.toString();
            _Content = result.rawContent.toString();
            _Format = result.format.toString().toUpperCase();
          });
          print(result.type); // The result type (barcode, cancelled, failed)
          print(result.rawContent); // The barcode content
          print(result.format); // The barcode format (as enum)
          print(result.formatNote); // If a unknown format was scanned this field contains a note
        },
        tooltip: 'Scan Barcode',
        child: Icon(Icons.photo_camera),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
