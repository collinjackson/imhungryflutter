import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:io';
import 'dart:async';
import 'recipejsonloader.dart';


import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(new ImHungryApp());
}

class ImHungryApp extends StatefulWidget {
  @override
  ImHungryAppState createState() => new ImHungryAppState();
}

class ImHungryAppState extends State<ImHungryApp> {
  DatabaseClient dbc;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    loadJSON();
  }

  Future initializeDatabase() async {
    dbc = new DatabaseClient();
    await dbc.create();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "I\'m Hungry",
      home: new MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("I\'m Hungry")
      ),
      body: new IHGridView(),
    );
  }
}

class IHGridView extends StatefulWidget {
  @override
  IHGridViewState createState() => new IHGridViewState();
}

class IHGridViewState extends State<IHGridView> {
  DatabaseClient dbc;
  var mylist = ["0", "1", "2"];
  String title = "EMPTY";

  @override
  void initState() {
    super.initState();
//    initializeDatabase();
//    loadJSON();

  }

  initializeDatabase() async {
//    dbc = new DatabaseClient();
//    await dbc.create();
  }

  Future<List> _getData() async {
    dbc = new DatabaseClient();
    await dbc.create();
    List<Recipe> list = await dbc.fetchLatestRecipes(10);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) {
            return new Container(child: new Center(
              child: new Text('EMPTY',
                style: new TextStyle(color: Colors.black),
              ),
            ),);
          }
          List items = snapshot.data;
          return new GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              Recipe item = items[index];
              Uint8List bytes = BASE64.decode(item.image_blob);
              return new Container(
                child: new Center(
                  child: new Image.memory(bytes),
                ),
              );
            },
          );
        },
      ),
    );
  }

  loadImageFromDB(int index) async {
    if (dbc!=null) {
      Recipe a = await dbc.fetchRecipe(1);
      mylist[index] = a.title;
      print("*** Loaded " + a.title);
    }
  }

  Widget gridItemBuilder(int index)  {
//    Recipe a = dbc.fetchRecipe(index);
//    Uint8List bytes = BASE64.decode(a.image_blob);
    loadImageFromDB(1);
    return new Text(mylist[index%3]);

  }

  Widget buildGrid() {
    return new GridView.builder(
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) => gridItemBuilder(index));
  }

} // end IHGridView

