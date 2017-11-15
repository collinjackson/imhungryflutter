import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:io';
import 'dart:async';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
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
  List<Widget> list = [];
  int recipeCount = 0;

  @override
  // Found related info here
  // https://stackoverflow.com/questions/45107702/flutter-timing-problems-on-stateful-widget-after-api-call
  void initState()  {
    super.initState();
     initializeDatabase();
     loadJSON();
  }

  Future initializeDatabase() async {

  }

  Future loadJSON() async {
    dbc = new DatabaseClient();
    await dbc.create();

    String recipesJSON = await rootBundle.loadString('res/recipes.json');
    Map decoded = JSON.decode(recipesJSON);

    for(var aRecipe in decoded['recipes']) {
      Recipe dbRecipe = new Recipe();
      dbRecipe.original_id = int.parse(aRecipe['original_id']);
      dbRecipe.title = aRecipe['title'];
      dbRecipe.image_blob = aRecipe['image_blob'];
      dbc.upsertRecipe(dbRecipe);
      await new Future.delayed(const Duration(milliseconds:10));  // to show that rendering does not happen between iterations

      Uint8List bytes = BASE64.decode(dbRecipe.image_blob);
      setState(() {
        list.add(new Container(
          child: new Image.memory(bytes),
        ));
        recipeCount++;
      });

      print (dbRecipe.title);
    }
//  await dbc.close();
  }

  Future<List> _getData() async {
    dbc = new DatabaseClient();
    await dbc.create();
    list = await dbc.fetchLatestRecipes(500);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:  new GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) => list[index],
          ),
      );
  }
} // end IHGridView

