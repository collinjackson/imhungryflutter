import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'database.dart';

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
    dbRecipe.original_id = decoded['original_id'];
    dbRecipe.title = decoded['title'];
    dbRecipe.image_blob = decoded['image_blog'];
    print (aRecipe['title']);
  }
}