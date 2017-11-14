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
    dbRecipe.original_id = int.parse(aRecipe['original_id']);
    dbRecipe.title = aRecipe['title'];
    dbRecipe.image_blob = aRecipe['image_blog'];
    dbc.upsertRecipe(dbRecipe);
    print (aRecipe['title']);
  }
//  await dbc.close();
}