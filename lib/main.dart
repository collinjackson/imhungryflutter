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

  @override
  void initState() {
    super.initState();
    initializeDatabase();
//    loadJSON();

  }

  initializeDatabase() async {
    dbc = new DatabaseClient();
    await dbc.create();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: buildGrid(),
    );
  }

  loadImageFromDB(int index) async {
    if (dbc!=null) {
      Recipe a = await dbc.fetchRecipe(1);
      mylist[index] = a.title;
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

//    Recipe aRecipe = new Recipe();
//    aRecipe.original_id = 1;
//    aRecipe.title = "First Recipe";
//
//    aRecipe = await dbc.upsertRecipe(aRecipe);
//    print(aRecipe.title);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "I\'m Hungry",
      home: new MainScreen(),
    );
  }
}