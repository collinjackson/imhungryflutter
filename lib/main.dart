import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:io';
import 'dart:async';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'database.dart';
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
  List<Recipe> list = [];

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

  Future<String> _loadJSON() async {
    return await rootBundle.loadString('res/recipes.json');
  }

  Future loadJSON() async {
    DatabaseClient dbc = new DatabaseClient();
    await dbc.create();

    String recipesJSON = await _loadJSON();
    print(recipesJSON);
    Map decoded = JSON.decode(recipesJSON);

    for(var aRecipe in decoded['recipes']) {
      Recipe dbRecipe = new Recipe();
      dbRecipe.original_id = int.parse(aRecipe['original_id']);
      dbRecipe.title = aRecipe['title'];
      dbRecipe.image_blob = aRecipe['image_blob'];
      dbc.upsertRecipe(dbRecipe);
      print (aRecipe['title']);
    }
//  await dbc.close();
  }

  Future<List> _getData() async {
    dbc = new DatabaseClient();
    await dbc.create();
    list = await dbc.fetchLatestRecipes(20);
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
              child: new Text('Please wait...',
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

