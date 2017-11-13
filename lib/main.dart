import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:io';
import 'dart:async';

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


class IHGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new GridView.count(
        crossAxisCount: 4,
        children: new List<Widget>.generate(16, (index) {
          return new GridTile(
            child: new Card(
                color: Colors.blue.shade200,
                child: new Center(
                  child: new Text('tile $index'),
                )
            ),
          );
        }),
      ),
    );
  }
}


class ImHungryAppState extends State<ImHungryApp> {
  DatabaseClient dbc;

  @override
  void initState() {
    super.initState();
    createFirstRecipe();

  }

  Future createFirstRecipe() async {
    dbc = new DatabaseClient();

    await dbc.create();

    Recipe aRecipe = new Recipe();
    aRecipe.original_id = 1;
    aRecipe.title = "First Recipe";

    aRecipe = await dbc.upsertRecipe(aRecipe);
    print(aRecipe.title);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "I\'m Hungry",
      home: new MainScreen(),
    );
  }
}