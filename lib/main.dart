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

// App
// Initialize database. Load MainScreen().
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

// MainScreen
// Set up app. Load IHGridView()
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

// IHGridViewState
// Load data from database. Render GridView.
class IHGridViewState extends State<IHGridView> {
  DatabaseClient dbc;

  @override
  void initState() {
    super.initState();
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
} // end IHGridView

